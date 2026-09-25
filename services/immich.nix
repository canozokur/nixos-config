{
  config,
  lib,
  mkReverseProxyService,
  ...
}:
let
  addr = config.box.networking.lanIP;
  iface = config.box.networking.lanInterface;
  mountPoint = "/mnt/immich-data";
  pgMountPoint = "/var/lib/postgresql";
  uid = 329;
  gid = uid;
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  config = lib.mkIf config.services.immich.enable {
    users.users.immich = {
      uid = lib.mkIf (config.services.immich.user == "immich") uid;
      home = mountPoint;
      createHome = false;
    };
    users.groups.immich.gid = lib.mkIf (config.services.immich.group == "immich") gid;

    fileSystems.${mountPoint} = {
      device = "/dev/disk/by-uuid/60cb89a7-53ac-48ff-a1df-f8a3fd326ab4";
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

    fileSystems.${pgMountPoint} = {
      device = "/dev/disk/by-uuid/128a5f4a-bf92-4058-b7d0-e629f54ea5ef";
      fsType = "ext4";
      options = [
        "nofail"
        "_netdev"
        "auto"
        "exec"
        "defaults"
        "X-mount.owner=postgres"
        "X-mount.group=postgres"
      ];
    };

    services.immich = {
      host = addr;
      mediaLocation = mountPoint;
      machine-learning.environment = {
        HF_XET_CACHE = "${mountPoint}/cache/huggingface-xet";
      };
    };

    systemd.services.immich-server.unitConfig.RequiresMountsFor = mountPoint;
    systemd.services.immich-machine-learning.unitConfig.RequiresMountsFor = mountPoint;

    services.reverseProxy.contribs = mkReverseProxyService {
      inherit config lib;
      name = "immich";
      inherit (config.services.immich) port;
      websocket = true;
      # unlimited upload size, nginx default of 1M would break uploads
      locationExtraConfig = ''
        client_max_body_size 0;
      '';
      exposure = "internal";
      # SSO via authelia. service:role group convention: both groups grant
      # access; immich:admin maps to the admin role claim. Authorization
      # policy "immich" is generated from `groups`.
      oidc = {
        client_id = "immich";
        client_name = "Immich";
        client_secret_file = "authelia/clients/immich";
        groups = [
          "immich:user"
          "immich:admin"
        ];
        role_claim = {
          claim = "immich_role";
          # CEL, evaluated by authelia per login against the user's groups
          expression = "'immich:admin' in groups ? 'admin' : 'user'";
        };
        authorization_policy = "immich";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://immich.pco.pink/auth/login"
          "https://immich.pco.pink/user-settings"
          "app.immich:///oauth-callback"
        ];
        scopes = [
          "openid"
          "email"
          "profile"
        ];
        response_types = [ "code" ];
        grant_types = [ "authorization_code" ];
        token_endpoint_auth_method = "client_secret_post";
      };
    };

    services.consul.agentServices = [
      {
        name = "immich";
        address = addr;
        port = config.services.immich.port;
        checks = [
          {
            id = "immich-check";
            name = "Immich server on ${toString config.services.immich.port}";
            tcp = "${addr}:${toString config.services.immich.port}";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
    ];

    networking.firewall.interfaces.${iface}.allowedTCPPorts = [
      config.services.immich.port
    ];
  };
}
