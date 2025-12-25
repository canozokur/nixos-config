{ config, ... }:
let
  _m = config._meta;
in
{
  imports = [
    ./capabilities/prometheus.nix
    ./capabilities/grafana.nix
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  _meta.nginx = {
    upstreams = {
      grafana = {
        servers."${_m.networks.internalIP}:2324" = {};
      };
    };
    vhosts = {
      "grafana.lan" = {
        listen = [{ addr = "192.168.1.254"; port = 80; }];
        locations = {
          "/" = {
            proxyPass = "http://grafana";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };

  fileSystems."/mnt/prometheus-data" = {
    device = "/dev/disk/by-uuid/301a494c-6b1a-4bc6-9b43-2a33870fda3e";
    fsType = "ext4";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };

  # wait for the mount to be available to start
  systemd.services.prometheus.unitConfig = { RequiresMountsFor = "/mnt/prometheus-data"; };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - /mnt/prometheus-data"
  ];
}
