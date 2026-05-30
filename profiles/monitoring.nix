{
  config,
  helpers,
  inputs,
  ...
}:
let
  _m = config._meta;
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
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
        servers."${_m.networks.internalIP}:2324" = { };
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
