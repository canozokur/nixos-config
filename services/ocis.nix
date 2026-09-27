{
  pkgs,
  config,
  lib,
  helpers,
  inputs,
  mkReverseProxyService,
  ...
}:
let
  addr = config.box.networking.lanIP;
  iface = config.box.networking.lanInterface;
  mountPoint = "/mnt/ocis-data";
  uid = 328;
  gid = uid;
  # the fleet authelia host, or null; the SSO env block below only exists
  # when authelia is enabled somewhere in the fleet (grafana pattern)
  authelia = helpers.getAuthelia inputs.self.nixosConfigurations;
  autheliaDomain = "auth.pco.pink";
  # oCIS's built-in CSP blocks the browser from fetching the external IDP
  # (discovery/jwks), so replicate the default with the issuer in connect-src.
  cspYaml = pkgs.writeText "ocis-csp.yaml" ''
    directives:
      child-src:
        - "'self'"
      connect-src:
        - "'self'"
        - "blob:"
        - "https://${autheliaDomain}"
        - "https://raw.githubusercontent.com/owncloud/awesome-ocis/"
      default-src:
        - "'none'"
      font-src:
        - "'self'"
        - "'data:'"
      frame-ancestors:
        - "'self'"
      frame-src:
        - "'self'"
        - "blob:"
        - "https://embed.diagrams.net/"
      img-src:
        - "'self'"
        - "'data:'"
        - "blob:"
        - "https://raw.githubusercontent.com/owncloud/awesome-ocis/"
      manifest-src:
        - "'self'"
      media-src:
        - "'self'"
      object-src:
        - "'self'"
        - "blob:"
      script-src:
        - "'self'"
        - "'unsafe-inline'"
      style-src:
        - "'self'"
        - "'unsafe-inline'"
  '';

  # Shared between all four clients: who may use the service at all.
  ocisGroups = [
    "owncloud:user"
    "owncloud:admin"
  ];

  # Native app client: ids and secrets are public constants shipped inside
  # the app binaries (upstream docs list them verbatim). Desktop binds a
  # random loopback port per launch; authelia accepts any port against the
  # registered loopback URIs (RFC 8252 7.3). authorization_policy names the
  # generated per-client policy.
  mkNativeClient = client_id: client_name: client_secret: redirect_uris: {
    inherit client_id client_name client_secret redirect_uris;
    authorization_policy = client_id;
    groups = ocisGroups;
    require_pkce = true;
    pkce_challenge_method = "S256";
    scopes = [
      "openid"
      "offline_access"
      "profile"
      "email"
      "groups"
    ];
    response_types = [ "code" ];
    grant_types = [
      "authorization_code"
      "refresh_token"
    ];
    token_endpoint_auth_method = "client_secret_basic";
    access_token_signed_response_alg = "none";
    userinfo_signed_response_alg = "none";
    lifespan = "ocis";
  };
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  options.services.ocis.domain = lib.mkOption {
    type = lib.types.str;
    default = "files.pco.pink";
    description = "The vhost the internal reverse proxy serves this backend on.";
  };

  config = lib.mkIf config.services.ocis.enable {
    users.users.ocis.uid = lib.mkIf (config.services.ocis.user == "ocis") uid;
    users.groups.ocis.gid = lib.mkIf (config.services.ocis.group == "ocis") gid;

    fileSystems.${mountPoint} = {
      # uuid printed by `just provision-lun ocis 100G`
      device = "/dev/disk/by-uuid/223e9908-06b0-4238-ad60-96ae7df390bb";
      fsType = "ext4";
      options = [
        "nofail"
        "_netdev"
        "auto"
        "defaults"
        "X-mount.owner=${toString uid}"
        "X-mount.group=${toString gid}"
      ];
    };

    sops.secrets."ocis/admin-password" = {
      owner = "ocis";
      group = "ocis";
    };

    services.ocis = {
      package = pkgs.ocis-bin;
      address = addr;
      configDir = "${mountPoint}/config";
      stateDir = "${mountPoint}/data";
      url = "https://${config.services.ocis.domain}";
      environment = {
        # TLS terminates at the internal reverse proxy; OCIS_INSECURE alone
        # does not turn off the proxy's own listener TLS (PROXY_TLS defaults
        # true)
        OCIS_INSECURE = "true";
        PROXY_TLS = "false";
        # web defaults to 0.0.0.0:9100, which is node-exporter's tailnet
        # port; only the proxy needs web, discovered via the internal registry
        WEB_HTTP_ADDR = "${addr}:9110";
      } // lib.optionalAttrs (authelia != null) {
        # SSO via authelia. PROXY_* configures oCIS's own embedded proxy
        # (the component doing the OIDC dance), not the fleet nginx.
        OCIS_OIDC_ISSUER = "https://${autheliaDomain}";
        PROXY_OIDC_REWRITE_WELLKNOWN = "true";
        PROXY_CSP_CONFIG_FILE_LOCATION = toString cspYaml;
        PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
        PROXY_OIDC_SKIP_USER_INFO = "false";
        PROXY_OIDC_INSECURE = "false";
        WEB_OIDC_CLIENT_ID = "ocis";
        # the ocis scope only carried the role claim, which native clients
        # can never receive (fixed app scopes)
        WEB_OIDC_SCOPE = "openid profile email";
        PROXY_USER_OIDC_CLAIM = "preferred_username";
        PROXY_USER_CS3_CLAIM = "username";
        PROXY_AUTOPROVISION_ACCOUNTS = "true";
        # native clients carry no role claim, so roles come from oCIS
        # storage: default user role on first login, admins assigned in the
        # settings UI
        GRAPH_ASSIGN_DEFAULT_USER_ROLE = "true";
        OCIS_ADMIN_USER_ID = "";
        OCIS_EXCLUDE_RUN_SERVICES = "idp";
        GRAPH_USERNAME_MATCH = "none";
      };
    };

    # bootstraps ocis.yaml (with its generated secrets) onto the LUN on first
    # start; an already-initialized LUN skips straight to the service
    systemd.services.ocis-init = {
      description = "oCIS first-run init";
      before = [ "ocis.service" ];
      unitConfig = {
        RequiresMountsFor = mountPoint;
        ConditionPathExists = "!${mountPoint}/config/ocis.yaml";
      };
      environment = {
        OCIS_URL = "https://${config.services.ocis.domain}";
        OCIS_BASE_DATA_PATH = "${mountPoint}/data";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "ocis";
        Group = "ocis";
        UMask = "0077";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ocis-init" ''
          ${lib.getExe pkgs.ocis-bin} init \
            --config-path ${mountPoint}/config \
            --admin-password "$(cat ${config.sops.secrets."ocis/admin-password".path})" \
            --insecure true
        '';
      };
    };

    systemd.services.ocis = {
      requires = [ "ocis-init.service" ];
      after = [ "ocis-init.service" ];
      unitConfig.RequiresMountsFor = mountPoint;
    };

    services.reverseProxy.contribs = mkReverseProxyService {
      inherit config lib;
      name = "ocis";
      domain = config.services.ocis.domain;
      inherit (config.services.ocis) port;
      websocket = true;
      # unlimited upload size, nginx default of 1M would break file sync
      locationExtraConfig = ''
        client_max_body_size 0;
      '';
      exposure = "internal";
      # SSO via authelia: the web client plus the three native-app clients.
      # `groups` gates access; each client gets its own generated policy.
      oidc = [
        {
          client_id = "ocis";
          client_name = "ownCloud Infinite Scale";
          public = true;
          groups = ocisGroups;
          authorization_policy = "ocis";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://files.pco.pink/"
            "https://files.pco.pink/oidc-callback.html"
            "https://files.pco.pink/oidc-silent-redirect.html"
            "https://files.pco.pink/apps/openidconnect/redirect"
          ];
          scopes = [
            "openid"
            "offline_access"
            "groups"
            "profile"
            "email"
          ];
          response_types = [ "code" ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          token_endpoint_auth_method = "none";
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          lifespan = "ocis";
        }
        (mkNativeClient
          "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69"
          "ownCloud Infinite Scale (Desktop)"
          "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh"
          [
            "http://127.0.0.1"
            "http://localhost"
          ])
        (mkNativeClient
          "e4rAsNUSIUs0lF4nbv9FmCeUkTlV9GdgTLDH1b5uie7syb90SzEVrbN7HIpmWJeD"
          "ownCloud Infinite Scale (Android)"
          "dInFYGV33xKzhbRmpqQltYNdfLdJIfJ9L5ISoKhNoT9qZftpdWSP71VrpGR9pmoD"
          [ "oc://android.owncloud.com" ])
        (mkNativeClient
          "mxd5OQDk6es5LzOzRvidJNfXLUZS2oN3oUFeXPP8LpPrhx3UroJFduGEYIBOxkY1"
          "ownCloud Infinite Scale (iOS)"
          "KFeFWWEZO9TkisIQzR3fo7hfiMXlOpaqP8CFuTbSHzV1TUuGECglPxpiVKJfOXIx"
          [
            "oc://ios.owncloud.com"
            "oc.ios://ios.owncloud.com"
          ])
      ];
    };

    services.consul.agentServices = [
      {
        name = "ocis";
        address = addr;
        port = config.services.ocis.port;
        checks = [
          {
            id = "ocis-check";
            name = "oCIS proxy on ${toString config.services.ocis.port}";
            tcp = "${addr}:${toString config.services.ocis.port}";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
    ];

    networking.firewall.interfaces.${iface}.allowedTCPPorts = [
      config.services.ocis.port
    ];
  };
}
