{ config, ... }:
let
  port = config.services.prowlarr.settings.server.port;
  addr = config._meta.networks.internalIP;
in
{
  imports = [
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  _meta.nginx = {
    upstreams = {
      prowlarr = {
        servers."${addr}:${toString port}" = { };
      };
    };
    vhosts = {
      "prowlarr.pco.pink" = {
        listen = [
          {
            addr = "192.168.1.253";
            port = 443;
            ssl = true;
          }
        ];
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://prowlarr";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection $http_connection;
              proxy_redirect     off;
              proxy_http_version 1.1;
            '';
          };
        };
      };
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
