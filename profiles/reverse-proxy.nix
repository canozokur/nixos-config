{ helpers, inputs, lib, pkgs, config, ... }:
let
  externalIP = "192.168.1.254";
  internalIP = "192.168.1.253";
  defaultIndex = pkgs.writeTextDir "defaultVhost/index.html" (builtins.readFile ./files/nginx/defaultIndex.html);
  serversWithVhosts = helpers.getHostsWith inputs.self.nixosConfigurations ["nginx" "vhosts"];
  buildDnsCfg = lib.mapAttrsToList (name: node:
    lib.mapAttrsToList (d: c:
      let
        listenList = c.listen or [];
        customIps = builtins.filter (x: x != null)
          (builtins.map (e: e.addr or null) listenList);
        finalIps = if customIps != [] then customIps else [ internalIP ];
      in
      builtins.map (ip:
        { domain = d; ip = ip; }
      ) finalIps
    ) node.config._meta.nginx.vhosts
  );

  sslDomains = [ "pco.pink" ];
  acmeCerts = lib.pipe serversWithVhosts [
    (lib.mapAttrsToList (_: node: node.config._meta.nginx.vhosts))
    (lib.foldl' (acc: set: acc // set) {})
    lib.attrsToList
    (builtins.filter (item:
      lib.any (suffix: lib.hasSuffix suffix item.name) sslDomains
    ))
    (map (item: {
      name = item.name;
      value = {
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare".path;
        group = "nginx";
        extraDomainNames = item.value.serverAliases or [];
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

    networks.wiredAddresses = [
      externalIP
      internalIP
    ];

    # default vhosts
    nginx = {
      vhosts = {
        "pco.pink" = {
          listen = [
            { addr = "192.168.1.253"; port = 80; }
            { addr = "192.168.1.254"; port = 80; }
          ];
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
