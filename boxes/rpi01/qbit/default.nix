{
  config,
  lib,
  mkReverseProxyService,
  ...
}:
{
  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "qbit";
    subdomain = "qbit";
    port = 8080;
    backendAddr = "192.168.1.129";
    extraConfig = ''
      client_max_body_size 0; # disable max upload size for nzbs
    '';
  };
}
