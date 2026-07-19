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
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

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

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "2y";
    scrapeConfigs = [
      {
        job_name = "self";
        static_configs = [
          {
            targets = [ "localhost:9090" ];
          }
        ];
      }
      {
        job_name = "consul";
        consul_sd_configs = [
          {
            server = "consul.lan:8500";
          }
        ];
        # relabel configuration for consul server metrics
        # documentation: https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
        relabel_configs = [
          {
            source_labels = [
              "__address__"
              "__meta_consul_service"
            ];
            separator = ":";
            regex = "(.*):(8300):(consul)";
            target_label = "__address__";
            replacement = "\${1}:8500";
          }
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "consul";
            target_label = "__param_format";
            replacement = "prometheus";
          }
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "consul";
            target_label = "__metrics_path__";
            replacement = "/v1/agent/metrics";
          }
        ];
      }
    ];
  };

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
