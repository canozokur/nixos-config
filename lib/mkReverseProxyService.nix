{ inputs, helpers }:
# `config` and `lib` are required: they come from the calling module's
# function args, not from specialArgs.
{
  config,
  lib,
  name,
  port,
  subdomain ? name,
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
  ${name} = {
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
