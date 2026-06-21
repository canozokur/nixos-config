{
  config,
  lib,
  helpers,
  inputs,
  mkReverseProxyService,
  ...
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
in
{
  imports = [
    ./base/prometheus.nix
    ./base/grafana.nix
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "grafana";
    subdomain = "grafana";
    port = 2324;
    listenAddr = proxy.externalIP;
  };

  systemd.services.prometheus.unitConfig = {
    RequiresMountsFor = "/mnt/prometheus-data";
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - /mnt/prometheus-data"
  ];
}
