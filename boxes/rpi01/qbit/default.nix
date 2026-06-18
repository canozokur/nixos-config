{
  inputs,
  helpers,
  ...
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
in
{
  _meta.nginx.upstreams.qbit.servers."192.168.1.129:8080" = { };
  _meta.nginx.vhosts."qbit.pco.pink" = {
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
      proxyPass = "http://qbit";
      recommendedProxySettings = true;
    };
  };
}
