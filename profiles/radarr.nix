{ config, lib, ... }:
let
  port = config.services.radarr.settings.server.port;
  addr = config._meta.networks.internalIP;
  mountPoint = "/mnt/radarr-data";
  uid = config.ids.uids.radarr;
  gid = 568;
in
{
  imports = [
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  _meta.nginx = {
    upstreams = {
      radarr = { servers."${addr}:${toString port}" = {}; };
    };
    vhosts = {
      "radarr.pco.pink" = {
        listen = [{ addr = "192.168.1.253"; port = 443; ssl = true; }];
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://radarr";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection $http_connection;
              proxy_redirect     off;
              proxy_http_version 1.1;
            '';
          };
        };
      };
    };
  };

  users.groups = { media = { inherit gid; }; };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    dataDir = mountPoint;
  };

  systemd.services.radarr.unitConfig = { RequiresMountsFor = mountPoint; };

  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/1c44502d-eda8-4c27-9bac-b891618f52bf";
    fsType = "xfs";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };

  systemd.tmpfiles.rules = [
    # Type Path        Mode    UID                GID             Age  Argument
    "d ${mountPoint}   0775    ${toString uid}   ${toString gid}  -    -"
  ];

  # using mkDefault because other profiles might mount the same thing
  fileSystems."/shared" = lib.mkDefault {
    device = "192.168.0.100:/mnt/main/k8s/vols/pvc-924a7cdb-6593-4a3b-b498-3fb965cc9ef6";
    fsType = "nfs";
    options = [ "nconnect=16" ];
  };
}
