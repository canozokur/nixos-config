{
  helpers,
  lib,
  inputs,
  pkgs,
  constants,
  config,
  ...
}:
let
  contribHosts = helpers.getHostsWith inputs.self.nixosConfigurations [
    "services"
    "reverseProxy"
    "contribs"
  ];
  allVhosts = lib.foldl' lib.mergeAttrs { } (
    lib.concatMap (host:
      lib.mapAttrsToList (_: c: c.vhosts) host.config.services.reverseProxy.contribs
    ) (lib.attrValues contribHosts)
  );
  defaultIndex = pkgs.writeTextDir "defaultVhost/index.html" (
    builtins.readFile ./files/nginx/defaultIndex.html
  );
  proxy = {
    internalIP = config.services.reverseProxy.host.internalIP;
    externalIP = config.services.reverseProxy.host.externalIP;
  };
  sslDomains = constants.fleet.domains.ssl;
  acmeCerts = lib.pipe allVhosts [
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
    ./base/nginx.nix
    ./base/consul.nix
  ];

  # `services.reverseProxy.contribs` is declared in modules/host-options.nix so
  # the option exists on hosts that don't load this module (e.g. rpi01 with
  # emby/nzbget glue files). Only `host` is declared here since only the proxy
  # host loads this module.
  options.services.reverseProxy.host = {
    enable = lib.mkEnableOption "This host runs the fleet reverse proxy.";
    internalIP = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The internal-facing IP the reverse proxy listens on.";
    };
    externalIP = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The external-facing IP the reverse proxy listens on.";
    };
  };

  config = lib.mkIf config.services.reverseProxy.host.enable {
    services.reverseProxy.contribs.default-vhost = {
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
      upstreams = { };
    };

    services.pihole.extraStaticHosts = lib.flatten (
      lib.mapAttrsToList (
        name: c:
        let
          listenList = c.listen or [ ];
          customIps = builtins.filter (x: x != null) (builtins.map (e: e.addr or null) listenList);
          finalIps = if customIps != [ ] then customIps else [ proxy.internalIP ];
        in
        builtins.map (ip: {
          domain = name;
          ip = ip;
        }) finalIps
      ) allVhosts
    );

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
  };
}
