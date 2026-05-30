{
  helpers,
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  constants = import ../lib/constants.nix;
  proxy = config._meta.services.reverseProxy;
  defaultIndex = pkgs.writeTextDir "defaultVhost/index.html" (
    builtins.readFile ./files/nginx/defaultIndex.html
  );
  serversWithVhosts = helpers.getHostsWith inputs.self.nixosConfigurations [
    "nginx"
    "vhosts"
  ];
  buildDnsCfg = lib.mapAttrsToList (
    name: node:
    lib.mapAttrsToList (
      d: c:
      let
        listenList = c.listen or [ ];
        customIps = builtins.filter (x: x != null) (builtins.map (e: e.addr or null) listenList);
        finalIps = if customIps != [ ] then customIps else [ proxy.internalIP ];
      in
      builtins.map (ip: {
        domain = d;
        ip = ip;
      }) finalIps
    ) node.config._meta.nginx.vhosts
  );

  sslDomains = constants.fleet.domains.ssl;
  acmeCerts = lib.pipe serversWithVhosts [
    (lib.mapAttrsToList (_: node: node.config._meta.nginx.vhosts))
    (lib.foldl' (acc: set: acc // set) { })
    lib.attrsToList
    (builtins.filter (item: lib.any (suffix: lib.hasSuffix suffix item.name) sslDomains))
    (map (item: {
      name = item.name;
      value = {
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare".path;
        group = "nginx";
        extraDomainNames = item.value.serverAliases or [ ];
      };
    }))
    lib.listToAttrs
  ];
in
{
  imports = [
    ./capabilities/nginx.nix
    ./capabilities/consul.nix
  ];

  _meta = {
    dnsConfigurations = lib.flatten (buildDnsCfg serversWithVhosts);

    # default vhosts
    nginx = {
      vhosts = {
        "pco.pink" = {
          listen = [
            {
              addr = proxy.internalIP;
              port = 80;
            }
            {
              addr = proxy.internalIP;
              port = 443;
              ssl = true;
            }
            {
              addr = proxy.externalIP;
              port = 80;
            }
            {
              addr = proxy.externalIP;
              port = 443;
              ssl = true;
            }
          ];
          serverAliases = [ "www.pco.pink" ];
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
          default = true;
          root = "${defaultIndex}/defaultVhost";
          locations."/".index = "index.html";
        };
      };
    };
  };

  sops.secrets."cloudflare" = {
    owner = config.systemd.services.acme-setup.serviceConfig.User;
    group = config.systemd.services.acme-setup.serviceConfig.Group;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ssladmin@pco.pink";
    defaults.reloadServices = [ "nginx" ];
    certs = acmeCerts;
  };
}
