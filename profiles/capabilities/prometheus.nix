{ ... }:
{
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
}
