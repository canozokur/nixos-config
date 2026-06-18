{
  config,
  lib,
  helpers,
  inputs,
  constants,
  ...
}:
let
  proxy = helpers.getProxy inputs.self.nixosConfigurations;
  port = config.services.sonarr.settings.server.port;
  addr = config._meta.networks.internalIP;
  mountPoint = "/mnt/sonarr-data";
  uid = config.ids.uids.sonarr;
  gid = 568;
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.reverseProxy.contribs.sonarr = {
    upstreams = {
      sonarr = {
        servers."${addr}:${toString port}" = { };
      };
    };
    vhosts = {
      "sonarr.pco.pink" = {
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
        locations = {
          "/" = {
            proxyPass = "http://sonarr";
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

  users.groups = {
    media = { inherit gid; };
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    dataDir = mountPoint;
  };

  systemd.services.sonarr = {
    unitConfig.RequiresMountsFor = mountPoint;
    serviceConfig.UMask = lib.mkForce 0002;
  };

  systemd.tmpfiles.rules = [
    # Type Path        Mode    UID                GID             Age  Argument
    "d ${mountPoint}   0775    ${toString uid}   ${toString gid}  -    -"
  ];

  # using mkDefault because other services might mount the same thing
  fileSystems."/shared" = lib.mkDefault {
    device = "${constants.fleet.storage.truenas}:${constants.fleet.storage.sharedVolume}";
    fsType = "nfs";
    options = [ "nconnect=16" ];
  };
}
