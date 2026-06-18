{
  inputs,
  helpers,
  ...
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
in
{
  _meta.nginx.upstreams.emby.servers."192.168.1.129:8096" = { };
  _meta.nginx.vhosts."emby.pco.pink" = {
    listen = [
      {
        addr = proxy.internalIP;
        port = 443;
        ssl = true;
      }
    ];
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    # configuration from https://emby.media/community/index.php?/topic/93074-how-to-emby-with-nginx-with-csp-options/
    extraConfig = ''
      gzip on;
      gzip_disable "msie6";
      gzip_comp_level 6;
      gzip_min_length 1100;
      gzip_buffers 16 8k;
      gzip_proxied any;
      gzip_types
        text/plain
        text/css
        text/js
        text/xml
        text/javascript
        application/javascript
        application/x-javascript
        application/json
        application/xml
        application/rss+xml
        image/svg+xml;

      tcp_nodelay on;
      sendfile    off;
      proxy_buffering off;

      client_body_timeout   10;
      client_header_timeout 10;
      keepalive_timeout     30;
      send_timeout          10;
      keepalive_requests    10;
    '';
    locations = {
      "^~ /swagger".return = 404;
      "/" = {
        proxyPass = "http://emby";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
        '';
      };
    };
  };
}
