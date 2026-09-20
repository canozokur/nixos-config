{
  config,
  lib,
  ...
}:
let
  exporterPort = config.services.prometheus.exporters.node.port;
  # self MagicDNS name; the tailnet IP is only known at runtime, but this
  # name resolves at start just like the consul retry_join targets
  tailnetAddr = "${config.networking.hostName}.ts.pco.pink";
in
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = config.services.node-exporter.enabledCollectors;
      disabledCollectors = [ "zfs" ];
      # bind the tailnet name, matching the firewall scope below, so the
      # port stays free on the LAN and other interfaces
      listenAddress = tailnetAddr;
    };
  };

  # the name only resolves once tailscale is logged in; RestartSec keeps
  # the retry loop from tripping systemd's start limit
  systemd.services.prometheus-node-exporter = {
    after = [ "tailscaled.service" ];
    serviceConfig.RestartSec = 5;
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
          # the tailnet-name bind no longer answers on localhost
          http = "http://${tailnetAddr}:${toString exporterPort}";
          interval = "10s";
          timeout = "1s";
        }
      ];
    }
  ];
}
