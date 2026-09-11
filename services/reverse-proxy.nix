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
  # `role` picks which contribs this proxy host renders: the internal proxy
  # renders every contrib (dual render), public entry-point hosts render only
  # contribs marked exposure = "public".
  role = config.services.reverseProxy.host.role;
  visibleContribs = lib.filter (c: role == "internal" || c.exposure == "public") (
    lib.concatMap (host: lib.attrValues host.config.services.reverseProxy.contribs) (
      lib.attrValues contribHosts
    )
  );
  allVhosts = lib.foldl' lib.mergeAttrs { } (lib.map (c: c.vhosts) visibleContribs);
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
    role = lib.mkOption {
      type = lib.types.enum [ "internal" "public" ];
      default = "internal";
      description = ''
        internal: the proxy renders every contrib on its internalIP.
        public: entry-point host rendering only exposure = "public" contribs
        on its default listeners.
      '';
    };
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
    services.reverseProxy.contribs.default-vhost = lib.mkIf (role == "internal") {
      # Defined once, on the internal tier: public entry-point hosts render
      # this contrib through exposure = "public".
      exposure = "public";
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

    # LAN resolver records describe the internal tier only; public entry-point
    # hosts would duplicate every entry in the Pi-hole fold.
    services.pihole.extraStaticHosts = lib.mkIf (role == "internal") (
      lib.flatten (
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
    ));

    sops.secrets."cloudflare" = {
      owner = config.systemd.services.acme-setup.serviceConfig.User;
      group = config.systemd.services.acme-setup.serviceConfig.Group;
    };

    security.acme = {
      # mkDefault: proxy hosts that run another ACME module (headscale on
      # guild, derper on tr) set the same fields explicitly.
      acceptTerms = lib.mkDefault true;
      defaults.email = lib.mkDefault "ssladmin@pco.pink";
      defaults.reloadServices = lib.mkDefault [ "nginx" ];
      certs = acmeCerts;
    };
  };
}
