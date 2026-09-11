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
  # Visibility mirrors services/reverse-proxy.nix: the internal proxy renders
  # every contrib, public entry-point hosts render only exposure = "public".
  role = config.services.reverseProxy.host.role;
  contribVisible = c: role == "internal" || c.exposure == "public";
  flattenContribs = kind:
    lib.foldl' lib.mergeAttrs { } (
      lib.concatMap (host:
        lib.map (c:
          let
            value = c.${kind};
          in
          # Public rendering must not reuse the internal tier's listen lines
          # (they point at home LAN IPs); dropping `listen` falls through to
          # the vhost default (0.0.0.0).
          if kind == "vhosts" && role == "public" then
            lib.mapAttrs (_: v: builtins.removeAttrs v [ "listen" ]) value
          else
            value
        ) (lib.filter contribVisible (lib.attrValues host.config.services.reverseProxy.contribs))
      ) (lib.attrValues contribHosts)
    );
in
{
  options.services.nginx.elb = lib.mkEnableOption "This host is host to an nginx external load balancer.";

  config = {
    services.nginx = {
      enable = true;
      commonHttpConfig = ''
        log_format vhost '$host - $remote_addr - $remote_user [$time_local] "$request" '
          '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" $request_time';
        access_log /var/log/nginx/access.log vhost;
      '';
      virtualHosts = flattenContribs "vhosts";
      upstreams = flattenContribs "upstreams";
    } // lib.optionalAttrs (role == "internal") {
      # Public hosts keep the vhost-default binding (0.0.0.0); binding the
      # host default to box.networking.internalIP would also re-bind the
      # headscale/derper vhosts these hosts already serve.
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
    };

    # Consul registration publishes the internal tier's address; public
    # entry-point addresses aren't resolvable from the fleet scraper.
    services.consul.agentServices = lib.mkIf (role == "internal") [
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