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

  authelia = helpers.getAuthelia inputs.self.nixosConfigurations;
  # Vhosts to gate behind SSO. Resolved statically per contrib (no fleet
  # reads here - contribs must not depend on fleet authelia state): null
  # follows exposure, so public vhosts are gated unless a service opts out.
  gatedVhosts = lib.foldl' (acc: c:
    let gated = if c.forwardAuth == null then c.exposure == "public" else c.forwardAuth;
    in if gated then acc // lib.listToAttrs (map (n: lib.nameValuePair n true) (lib.attrNames c.vhosts)) else acc
  ) { } (lib.concatMap (host: lib.attrValues host.config.services.reverseProxy.contribs) (lib.attrValues contribHosts));

  # Authelia's auth-request flow: the verify subrequest targets the fleet
  # `authelia` upstream; the 401's Location header carries the portal
  # redirect (built from the session's authelia_url).
  authzLocation = {
    extraConfig = ''
      internal;
      proxy_pass http://authelia/api/authz/auth-request;
      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$host$request_uri;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";
      proxy_pass_request_body off;
    '';
  };
  gateLocation = loc: loc // {
    extraConfig = (loc.extraConfig or "") + ''
      auth_request /internal/authelia/authz;
      auth_request_set $redirection_url $upstream_http_location;
      error_page 401 =302 $redirection_url;
    '';
  };
  injectAuth = name: vhost:
    vhost // {
      locations =
        lib.mapAttrs (lname: loc:
          if lname == "/internal/authelia/authz" then loc else gateLocation loc
        ) (vhost.locations or { })
        // {
          "/internal/authelia/authz" = authzLocation;
        };
    };
in
{
  options.services.nginx.elb = lib.mkEnableOption "This host is host to an nginx external load balancer.";

  config = {
    assertions = [
      {
        assertion = authelia != null || gatedVhosts == { };
        message = "reverse-proxy: vhosts are gated behind fleet SSO (forwardAuth) but no Authelia is enabled in the fleet.";
      }
    ];

    services.nginx = {
      enable = true;
      commonHttpConfig = ''
        log_format vhost '$host - $remote_addr - $remote_user [$time_local] "$request" '
          '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" $request_time';
        access_log /var/log/nginx/access.log vhost;
      '';
      virtualHosts = lib.mapAttrs (name: vhost:
        # SSO gating applies to the public tier only: LAN clients hit the
        # internal proxy without auth, tailnet-roaming clients bypass via
        # authelia's internal-networks rule, internet clients get gated.
        if gatedVhosts ? ${name} && role == "public" then injectAuth name vhost else vhost
      ) (flattenContribs "vhosts");
      upstreams = flattenContribs "upstreams";
    } // lib.optionalAttrs (role == "internal") {
      # Public hosts keep the vhost-default binding (0.0.0.0); binding the
      # host default to box.networking.lanIP would also re-bind the
      # headscale/derper vhosts these hosts already serve.
      defaultListen = [
        {
          addr = "${config.box.networking.lanIP}";
          port = 80;
        }
        {
          addr = "${config.box.networking.lanIP}";
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
        address = config.box.networking.lanIP;
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