{
  helpers,
  lib,
  inputs,
  config,
  ...
}:
let
  contribHosts = helpers.getHostsWith inputs.self.nixosConfigurations [
    "services"
    "reverseProxy"
    "contribs"
  ];
  flattenContribs = kind:
    lib.foldl' lib.mergeAttrs { } (
      lib.concatMap (host:
        lib.mapAttrsToList (_: c: c.${kind}) host.config.services.reverseProxy.contribs
      ) (lib.attrValues contribHosts)
    );
in
{
  options.services.nginx.elb = lib.mkEnableOption "This host is host to an nginx external load balancer.";

  config = {
    services.nginx = {
      enable = true;
      defaultListen = [
        {
          addr = "${config.box.networking.internalIP}";
          port = 80;
        }
        {
          addr = "${config.box.networking.internalIP}";
          port = 443;
          ssl = true;
        }
      ];
      commonHttpConfig = ''
        log_format vhost '$host - $remote_addr - $remote_user [$time_local] "$request" '
          '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" $request_time';
        access_log /var/log/nginx/access.log vhost;
      '';
      virtualHosts = flattenContribs "vhosts";
      upstreams = flattenContribs "upstreams";
    };

    services.consul.agentServices = [
      {
        name = "nginx";
        tags = lib.optionals config.services.nginx.elb [ "elb" ];
        address = config.box.networking.internalIP;
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
      }
    ];

    networking.firewall = {
      allowedTCPPorts = [
        config.services.nginx.defaultHTTPListenPort
        config.services.nginx.defaultSSLListenPort
      ];
    };
  };
}
