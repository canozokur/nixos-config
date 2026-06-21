{
  config,
  lib,
  mkReverseProxyService,
  ...
}:
{
  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "bazarr";
    subdomain = "bazarr";
    port = 30046;
    backendAddr = "192.168.1.129";
    extraConfig = ''
      client_max_body_size 0; # disable max upload size for nzbs
    '';
    websocket = true;
  };
}
