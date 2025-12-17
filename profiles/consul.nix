{ config, lib, ... }:
let
  isServer = config._meta.services.consulServer;
  consulDomain = "consul.lan";
  consulPorts = {
    tcp = [
      8600 # dns
      8500 # http
      8501 # https
      8502 # grpc
      8503 # grpc tls
      8301 # lan serf
    ] ++ lib.optionals isServer [
      8300 # server rpc
      8302 # wan serf
    ];
    udp = [
      8600 # dns
      8301 # lan serf
    ] ++ lib.optionals isServer [
      8302 # wan serf
    ];
  };
in
{
  services.consul = {
    enable = true;
    webUi = isServer;
    interface.bind = lib.mkIf (config._meta.networks ? internalInterface) "${config._meta.networks.internalInterface}";
    extraConfig = {
      server = isServer;
      retry_join = [ consulDomain ];
      rejoin_after_leave = true;
      bootstrap_expect = if isServer then 3 else null;
      client_addr = "0.0.0.0";
      services = config.services.consul.agentServices;
      telemetry = {
        # prom default scrape interval is 10s
        # and the documentation suggests to use twice that value
        prometheus_retention_time = "20s";
        # according to documentation https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
        # we should disable hostnames
        disable_hostname = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = consulPorts.tcp;
    allowedUDPPorts = consulPorts.udp;
  };

  _meta.dnsConfigurations = lib.mkIf isServer [{
    ip = config._meta.networks.internalIP;
    domain = consulDomain;
  }];
}
