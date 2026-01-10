{ config, ... }:
let
  exporterPort = config.services.prometheus.exporters.node.port;
in
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
      enabledCollectors = config._meta.prometheus.enabledCollectors;
      disabledCollectors = [ "zfs" ];
    };
  };

  services.consul.agentServices = [
    {
      name = "node-exporter";
      tags = [ "server" ];
      address = config._meta.networks.internalIP;
      port = exporterPort;
      checks = [
        {
          id = "node-exporter-check";
          name = "HTTP on port ${toString exporterPort}";
          http = "http://localhost:${toString exporterPort}";
          interval = "10s";
          timeout = "1s";
        }
      ];
    }
  ];
}
