{
  config,
  lib,
  helpers,
  inputs,
  mkReverseProxyService,
  ...
}:
let
  cfg = config.services.authelia;
  instance = "main";
  domain = "auth.pco.pink";
  port = 9091;
  metricsPort = 9959;
  tailnetIface = config.box.networking.tailnet.interface;
  # 100.x address: cross-host nginx upstreams target it by IP because nginx
  # resolves upstream hostnames once at startup (MagicDNS would race
  # tailscaled at boot).
  tailnetIP = config.box.networking.tailnet.ip;

  # OIDC client registrations from every fleet reverse-proxy contrib
  # (mkReverseProxyService { oidc = { ... }; }). Each client must name the
  # sops key holding its secret digest via client_secret_file.
  contribOidcClients = lib.filter (c: c != null && c != { }) (
    lib.concatMap (
      host: lib.map (c: c.oidc) (lib.attrValues host.config.services.reverseProxy.contribs)
    ) (lib.attrValues (helpers.getHostsWith inputs.self.nixosConfigurations [
      "services"
      "reverseProxy"
      "contribs"
    ]))
  );

  clientSecretFile = c:
    let file = c.client_secret_file or null;
    in if file == null then
      throw "authelia oidc client ${c.client_id or "??"}: client_secret_file (sops key holding the client secret) is required"
    else file;

  # Authelia's template filter (active via the jwks key) reads the digest
  # from the sops-rendered file at startup; digests never land in the repo.
  # Repo-side meta fields are stripped; role-claim clients get their own
  # claims_policy (named after the client), everyone else the default one.
  fleetOidcClients = map (c:
    let file = clientSecretFile c;
    in (removeAttrs c [ "client_secret_file" "groups" "role_claim" ]) // {
      client_secret = "{{ secret \"${config.sops.secrets.${file}.path}\" }}";
      claims_policy = if (c.role_claim or null) != null then c.client_id else "default";
    }) contribOidcClients;

  clientSecretKeys = lib.unique (map clientSecretFile contribOidcClients);

  # Clients declaring `groups` get a per-client authorization policy named
  # after their client_id: default-deny, one allow rule per group. One
  # subject per rule; 4.39 evaluated multi-subject rules as AND not OR.
  groupClients = lib.filter (c: (c.groups or [ ]) != [ ]) contribOidcClients;
  oidcAuthorizationPolicies = lib.listToAttrs (map (c:
    lib.nameValuePair c.client_id {
      default_policy = "deny";
      rules = map (group: {
        policy = "one_factor";
        subject = "group:${group}";
      }) c.groups;
    }) groupClients);

  # Clients declaring `role_claim` emit that CEL-derived claim (e.g. the
  # Immich role, re-read on every SSO login); the expression lives in the
  # contrib next to the group convention it encodes.
  roleClaimClients = lib.filter (c: (c.role_claim or null) != null) contribOidcClients;
in
{
  imports = [ ./base/consul.nix ];

  options.services.authelia = {
    enable = lib.mkEnableOption ''
      the fleet Authelia SSO server (OIDC provider + forward-auth backend).
      Exactly one host fleet-wide should enable it; other modules detect it
      via helpers.getAuthelia.
    '';
    internalNetworks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "192.168.1.0/24"
        "192.168.0.0/24"
        "100.64.0.0/10"
      ];
      description = ''
        Source networks that bypass forward-auth gating: home LANs and the
        tailnet CGNAT range. Gated vhosts are reachable without a login from
        these sources (the proxies pass the client's real address as
        X-Forwarded-For); everyone else hits the portal.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = tailnetIP != null;
        message = "services.authelia.enable requires box.networking.tailnet.ip (cross-host nginx upstreams target the tailnet address).";
      }
      {
        assertion =
          (lib.unique (map (c: c.role_claim.claim) roleClaimClients)) == (map (c: c.role_claim.claim) roleClaimClients);
        message = "authelia oidc: two clients define the same role_claim.claim";
      }
    ];

    sops.secrets = {
      "authelia/jwt-secret" = {
        owner = "authelia-main";
        group = "authelia-main";
      };
      "authelia/storage-key" = {
        owner = "authelia-main";
        group = "authelia-main";
      };
      "authelia/oidc-hmac" = {
        owner = "authelia-main";
        group = "authelia-main";
      };
      "authelia/oidc-jwks" = {
        owner = "authelia-main";
        group = "authelia-main";
      };
      "authelia/users" = {
        owner = "authelia-main";
        group = "authelia-main";
      };
    } // lib.listToAttrs (
      map (key: lib.nameValuePair key {
        owner = "authelia-main";
        group = "authelia-main";
      }) clientSecretKeys
    );

    services.authelia.instances.${instance} = {
      enable = true;
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/jwt-secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storage-key".path;
        oidcHmacSecretFile = config.sops.secrets."authelia/oidc-hmac".path;
        oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidc-jwks".path;
      };
      settings = {
        log.level = "info";
        theme = "dark";
        server.address = "tcp://:${toString port}/";
        telemetry.metrics = {
          enabled = true;
          # all interfaces; the firewall scopes the port to the tailnet
          address = "tcp://:${toString metricsPort}";
        };
        authentication_backend.file.path = config.sops.secrets."authelia/users".path;
        definitions.user_attributes = lib.listToAttrs (map (c:
          lib.nameValuePair c.role_claim.claim {
            inherit (c.role_claim) expression;
          }) roleClaimClients);
        access_control = {
          # default-deny: forward-auth consumers only get in via a rule (or an
          # OIDC client's own authorization_policy). Internal sources bypass;
          # the rest needs one factor.
          default_policy = "deny";
          rules = [
            {
              domain = "*.pco.pink";
              networks = cfg.internalNetworks;
              policy = "bypass";
            }
            {
              domain = "*.pco.pink";
              policy = "one_factor";
            }
          ];
        };
        session.cookies = [
          {
            domain = "pco.pink";
            authelia_url = "https://${domain}";
          }
        ];
        storage.local.path = "/var/lib/authelia-${instance}/storage.db";
        notifier.filesystem.filename = "/var/lib/authelia-${instance}/notification.txt";
        identity_providers.oidc = {
          # 4.39 dropped scope claims from id tokens by default; relying
          # parties evaluate role/group paths against the id token first.
          claims_policies = {
            default.id_token = [
              "groups"
              "email"
              "email_verified"
              "preferred_username"
              "name"
            ];
          } // lib.listToAttrs (map (c:
            lib.nameValuePair c.client_id {
              id_token = [
                "groups"
                "email"
                "email_verified"
                "preferred_username"
                "name"
                c.role_claim.claim
              ];
              custom_claims.${c.role_claim.claim} = {
                attribute = c.role_claim.claim;
              };
            }) roleClaimClients);
          authorization_policies = oidcAuthorizationPolicies;
          clients = fleetOidcClients;
        };
      };
    };

    services.reverseProxy.contribs = mkReverseProxyService {
      inherit config lib;
      name = "authelia";
      inherit domain;
      inherit port;
      backendAddr = tailnetIP;
      exposure = "public";
      # the portal cannot gate itself
      forwardAuth = false;
    };

    services.consul.agentServices = [
      {
        name = "authelia";
        address = tailnetIP;
        inherit port;
        checks = [
          {
            id = "authelia-check";
            name = "Authelia on port ${toString port}";
            http = "http://${tailnetIP}:${toString port}/api/health";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
      {
        name = "authelia-metrics";
        address = tailnetIP;
        port = metricsPort;
        checks = [
          {
            id = "authelia-metrics-check";
            name = "Authelia metrics on port ${toString metricsPort}";
            http = "http://${tailnetIP}:${toString metricsPort}/metrics";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
    ];

    networking.firewall.interfaces.${tailnetIface}.allowedTCPPorts = [
      port
      metricsPort
    ];
  };
}
