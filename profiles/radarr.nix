{ config, ... }:
let
  port = config.services.radarr.settings.server.port;
  addr = config._meta.networks.internalIP;
  mountPoint = "/mnt/radarr-data";
  uid = config.ids.uids.radarr;
  gid = config.ids.gids.radarr;
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
      "radarr.lan" = {
        listen = [{ addr = "192.168.1.253"; port = 80; }];
        locations = {
          "/" = {
            proxyPass = "http://radarr";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
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
    "d ${mountPoint}   0755    ${toString uid}   ${toString gid}  -    -"
  ];
}
