{
  config,
  ...
}:
let
  exporterPort = config.services.prometheus.exporters.node.port;
in
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = config.services.node-exporter.enabledCollectors;
      disabledCollectors = [ "zfs" ];
    };
  };

  # reachable only over the tailnet (same scope as the consul agent),
  # so node-exporter is never exposed on a box's public interface
  networking.firewall.interfaces.${config.box.networking.tailnet.interface}.allowedTCPPorts = [
    exporterPort
  ];

  # no explicit address: the agent registers the node's advertised
  # (tailscale) address, so scrapes always ride the tailnet
  services.consul.agentServices = [
    {
      name = "node-exporter";
      tags = [ "server" ];
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
