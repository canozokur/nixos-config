{ inputs, helpers }:
# Build a reverse-proxy vhost/upstream contribution from a small typed signature.
#
# Wired into `specialArgs` by `lib/mkbox.nix`. Usage from a service module:
#
#   services.reverseProxy.contribs = mkReverseProxyService {
#     name = "sonarr";
#     subdomain = "sonarr";
#     port = config.services.sonarr.settings.server.port;
#     websocket = true;
#   };
#
# What it sets:
#   1. `services.reverseProxy.contribs.${name}.upstreams.${name}` — nginx
#      upstream pointing at the backend.
#   2. `services.reverseProxy.contribs.${name}.vhosts.${domain}` — nginx
#      vhost with ACME/SSL, the standard `recommendedProxySettings`, and any
#      caller-supplied extras.
#
# Defaults:
#   backendAddr = config.box.networking.internalIP
#                 (pass explicit IP for cross-host backends — e.g. emby on
#                  TrueNAS at 192.168.1.129)
#   listenAddr  = proxy.internalIP
#                 (pass proxy.externalIP for syncthing-style external binding)
#   domain      = "${subdomain}.pco.pink"
#   tls         = true
{
  config,
  lib,
  ...
}:
{
  name,
  subdomain,
  port,
  backendAddr ? null,
  listenAddr ? null,
  domain ? null,
  tls ? true,
  websocket ? false,
  extraConfig ? "",
  locationExtraConfig ? "",
  extraLocations ? { },
  extraListen ? [ ],
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
  effectiveDomain = if domain != null then domain else "${subdomain}.pco.pink";
  effectiveBackend =
    if backendAddr != null then backendAddr else config.box.networking.internalIP;
  effectiveListen = if listenAddr != null then listenAddr else proxy.internalIP;

  defaultListen = lib.optionals tls [
    {
      addr = effectiveListen;
      port = 443;
      ssl = true;
    }
  ] ++ extraListen;

  websocketConfig = lib.optionalString websocket ''
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection $http_connection;
    proxy_redirect     off;
    proxy_http_version 1.1;
  '';

  defaultLocation = {
    proxyPass = "http://${name}";
    recommendedProxySettings = true;
    extraConfig = lib.optionalString (websocket || locationExtraConfig != "") ''
      ${websocketConfig}${locationExtraConfig}
    '';
  };

  vhostValue =
    {
      listen = defaultListen;
      enableACME = tls;
      forceSSL = tls;
      acmeRoot = null;
      locations = {
        "/" = defaultLocation;
      } // extraLocations;
    }
    // lib.optionalAttrs (extraConfig != "") { inherit extraConfig; };
in
{
  services.reverseProxy.contribs.${name} = {
    upstreams = {
      ${name} = {
        servers."${effectiveBackend}:${toString port}" = { };
      };
    };
    vhosts = {
      ${effectiveDomain} = vhostValue;
    };
  };
}
