{
  config,
  helpers,
  inputs,
  ...
}:
let
  addr = config.box.networking.internalIP;
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
in
{
  imports = [
    ./base/prometheus.nix
    ./base/grafana.nix
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.reverseProxy.contribs.grafana = {
    upstreams = {
      grafana = {
        servers."${addr}:2324" = { };
      };
    };
    vhosts = {
      "grafana.pco.pink" = {
        listen = [
          {
            addr = proxy.externalIP;
            port = 443;
            ssl = true;
          }
        ];
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        locations = {
          "/" = {
            proxyPass = "http://grafana";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };

  # wait for the mount (declared by the host box) to be available to start
  systemd.services.prometheus.unitConfig = {
    RequiresMountsFor = "/mnt/prometheus-data";
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - /mnt/prometheus-data"
  ];
}
