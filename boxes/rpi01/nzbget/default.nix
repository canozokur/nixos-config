{
  inputs,
  helpers,
  ...
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
in
{
  services.reverseProxy.contribs.nzbget = {
    upstreams = {
      nzbget = {
        servers."192.168.1.129:6789" = { };
      };
    };
    vhosts = {
      "nzbget.pco.pink" = {
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
          proxyPass = "http://nzbget";
          recommendedProxySettings = true;
        };
      };
    };
  };
}
