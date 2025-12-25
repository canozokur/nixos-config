{ config, lib, ... }:
let
  port = config.services.prowlarr.settings.server.port;
  addr = config._meta.networks.internalIP;
in
{
  imports = [
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  _meta.nginx = {
    upstreams = {
      prowlarr = { servers."${addr}:${toString port}" = {}; };
    };
    internalVhosts = {
      "prowlarr.lan" = {
        locations = {
          "/" = {
            proxyPass = "http://prowlarr";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/mnt/prowlarr-data";
  };

  systemd.services.prowlarr.unitConfig = { RequiresMountsFor = "/mnt/prowlarr-data"; };

  fileSystems."/mnt/prowlarr-data" = {
    device = "/dev/disk/by-uuid/c7b9c1ad-557a-49ea-bef1-656829c3b529";
    fsType = "xfs";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };
}
