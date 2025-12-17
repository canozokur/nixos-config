{ config, ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
      enabledCollectors = [ "systemd" ];
      disabledCollectors = [ "zfs" ];
    };
  };

  services.consul.agentServices = [{
    name = "node-exporter";
    tags = ["server"];
    address = config._meta.networks.internalIP;
    port = config.services.prometheus.exporters.node.port;
    checks = [
      {
        id = "node-exporter-check";
        name = "HTTP on port 9100";
        http = "http://localhost:9100";
        interval = "10s";
        timeout = "1s";
      }
    ];
  }];
}
