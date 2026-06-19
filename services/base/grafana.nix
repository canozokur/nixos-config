{ config, ... }:
{
  sops.secrets."grafana/secret-key" = {
    owner = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;
    openFirewall = true;
    settings = {
      server.http_addr = "0.0.0.0";
      server.http_port = 2324;
      security.secret_key = "$__file{${config.sops.secrets."grafana/secret-key".path}}";
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
}
