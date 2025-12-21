{ helpers, lib, inputs, config, ... }:
let
  allVhosts = helpers.getHostsWith inputs.self.nixosConfigurations "virtualHosts";
  listVhosts = lib.mapAttrsToList (_: host: host.config._meta.virtualHosts) allVhosts;
  mergedVhosts = lib.foldl' (acc: set: acc // set) {} listVhosts;
in
{
  services.nginx = {
    enable = true;
    virtualHosts = mergedVhosts;
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
}
