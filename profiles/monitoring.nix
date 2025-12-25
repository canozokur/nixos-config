{ config, ... }:
let
  _m = config._meta;
in
{
  imports = [
    ./capabilities/monitoring.nix
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  _meta.nginx = {
      upstreams = {
        grafana = {
          servers."${_m.networks.internalIP}:2324" = {};
        };
      };
      externalVhosts = {
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
}
