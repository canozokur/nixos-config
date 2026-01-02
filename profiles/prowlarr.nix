{ config, ... }:
let
  port = config.services.prowlarr.settings.server.port;
  addr = config._meta.networks.internalIP;
  mountPoint = "/mnt/prowlarr-data";
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
    vhosts = {
      "prowlarr.pco.pink" = {
        listen = [{ addr = "192.168.1.253"; port = 443; ssl = true; }];
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://prowlarr";
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

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    dataDir = mountPoint;
  };

  systemd.services.prowlarr.unitConfig = { RequiresMountsFor = mountPoint; };

  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/c7b9c1ad-557a-49ea-bef1-656829c3b529";
    fsType = "xfs";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };
}
