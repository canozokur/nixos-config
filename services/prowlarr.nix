{ config, lib, mkReverseProxyService, ... }:
let
  port = config.services.prowlarr.settings.server.port;
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "prowlarr";
    subdomain = "prowlarr";
    inherit port;
    websocket = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
