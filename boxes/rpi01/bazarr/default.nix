{
  inputs,
  helpers,
  ...
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
in
{
  _meta.nginx.upstreams.bazarr.servers."192.168.1.129:30046" = { };
  _meta.nginx.vhosts."bazarr.pco.pink" = {
    extraConfig = ''
      client_max_body_size 0; # disable max upload size for nzbs
    '';
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
    locations."/" = {
      proxyPass = "http://bazarr";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection $http_connection;
        proxy_redirect     off;
        proxy_http_version 1.1;
      '';
    };
  };
}
