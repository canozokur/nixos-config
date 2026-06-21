{
  config,
  lib,
  mkReverseProxyService,
  ...
}:
{
  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "emby";
    subdomain = "emby";
    port = 8096;
    backendAddr = "192.168.1.129";
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
    websocket = true;
    extraLocations = {
      "^~ /swagger".return = 404;
    };
  };
}
