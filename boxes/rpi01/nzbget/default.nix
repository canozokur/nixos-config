{
  config,
  lib,
  mkReverseProxyService,
  ...
}:
{
  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "nzbget";
    subdomain = "nzbget";
    port = 6789;
    backendAddr = "192.168.1.129";
    extraConfig = ''
      client_max_body_size 0; # disable max upload size for nzbs
    '';
  };
}
