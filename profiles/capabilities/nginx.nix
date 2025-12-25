{ helpers, lib, inputs, config, ... }:
let
  allExternalVhosts = helpers.getHostsWith inputs.self.nixosConfigurations [ "nginx" "externalVhosts" ];
  allInternalVhosts = helpers.getHostsWith inputs.self.nixosConfigurations [ "nginx" "internalVhosts" ];
  allUpstreams = helpers.getHostsWith inputs.self.nixosConfigurations [ "nginx" "upstreams" ];
  extList = lib.mapAttrsToList (_: host: host.config._meta.nginx.externalVhosts) allExternalVhosts;
  intList = lib.mapAttrsToList (_: host: host.config._meta.nginx.internalVhosts) allInternalVhosts;
  mergedVhosts = lib.foldl' (acc: set: acc // set) {} (extList ++ intList);
in
{
  services.nginx = {
    enable = true;
    defaultListen = [ { addr = "${config._meta.networks.internalIP}"; port = 80; } { addr = "${config._meta.networks.internalIP}"; port = 443; ssl = true; } ];
    virtualHosts = mergedVhosts;
    upstreams = lib.mkMerge (
      lib.mapAttrsToList (_: host: host.config._meta.nginx.upstreams) allUpstreams
    );
  };

  services.consul.agentServices = [{
    name = "nginx";
    tags = lib.optionals (config._meta.services.elb == true) [ "elb" ];
    address = config._meta.networks.internalIP;
    port = config.services.nginx.defaultHTTPListenPort;
    checks = [
      {
        id = "nginx-check";
        name = "Nginx on port ${toString config.services.nginx.defaultHTTPListenPort}";
        tcp = "localhost:${toString config.services.nginx.defaultHTTPListenPort}";
        interval = "10s";
        timeout = "1s";
      }
    ];
  }];

  networking.firewall = {
    allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];
  };

}
