{
  inputs,
  helpers,
  config,
  lib,
  ...
}:
let
  isServer = config.services.consul.server.enable;
  consulDomain = "consul.pco.pink";
  consulServers = helpers.getHostsWith inputs.self.nixosConfigurations [
    "services"
    "consul"
    "server"
    "enable"
  ];
  retryJoin = map (h: "${h.config.networking.hostName}.ts.pco.pink") (
    lib.attrValues consulServers
  );
  consulPorts = {
    tcp = [
      8600 # dns
      8500 # http
      8501 # https
      8502 # grpc
      8503 # grpc tls
      8301 # lan serf
    ]
    ++ lib.optionals isServer [
      8300 # server rpc
      8302 # wan serf
    ];
    udp = [
      8600 # dns
      8301 # lan serf
    ]
    ++ lib.optionals isServer [
      8302 # wan serf
    ];
  };
in
{
  options.services.consul = {
    agentServices = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "List of services to register with the local Consul agent.";
    };
    server.enable = lib.mkEnableOption "This host is a Consul Server";
  };

  config = {
    services.consul = {
      enable = true;
      webUi = isServer;
      interface.bind = "tailscale0";
      extraConfig = {
        server = isServer;
        retry_join = retryJoin;
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

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = consulPorts.tcp;
      allowedUDPPorts = consulPorts.udp;
    };

    # tailscale0 must exist before the agent binds it.
    systemd.services.consul.after = [ "tailscaled.service" ];

    services.pihole.extraStaticHosts = lib.mkIf isServer [
      {
        ip = config.box.networking.internalIP;
        domain = consulDomain;
      }
    ];
  };
}
