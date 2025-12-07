{ config, lib, ... }:
{
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    openFirewall = true;
    settings = {
      server.http_addr = "0.0.0.0";
      server.http_port = 2324;
    };
    provision = {
      datasources.settings = {
        prune = true;
        datasources = [
          {
            name = "local prom";
            type = "prometheus";
            url = "http://localhost:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
  };

  fileSystems."/mnt/prometheus-data" = lib.mkIf (config.services.openiscsi.enable == true) {
    device = "/dev/disk/by-uuid/301a494c-6b1a-4bc6-9b43-2a33870fda3e";
    fsType = "ext4";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };

  systemd.tmpfiles.rules = lib.optionals (config.services.openiscsi.enable == true) [
    "D /mnt/prometheus-data 0751 prometheus prometheus - -"
    "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - /mnt/prometheus-data"
  ];
}
