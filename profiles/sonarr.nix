{ config, lib, ... }:
let
  port = config.services.sonarr.settings.server.port;
  addr = config._meta.networks.internalIP;
  mountPoint = "/mnt/sonarr-data";
  uid = config.ids.uids.sonarr;
  gid = 568;
in
{
  imports = [
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  _meta.nginx = {
    upstreams = {
      sonarr = {
        servers."${addr}:${toString port}" = { };
      };
    };
    vhosts = {
      "sonarr.pco.pink" = {
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
    serviceConfig.UMask = 0002;
  };

  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/9b9cea9d-b9a0-4115-ab64-40b53859f800";
    fsType = "xfs";
    options = [
      "nofail"
      "_netdev"
      "auto"
      "exec"
      "defaults"
    ];
  };

  systemd.tmpfiles.rules = [
    # Type Path        Mode    UID                GID             Age  Argument
    "d ${mountPoint}   0775    ${toString uid}   ${toString gid}  -    -"
  ];

  # using mkDefault because other profiles might mount the same thing
  fileSystems."/shared" = lib.mkDefault {
    device = "192.168.0.100:/mnt/main/k8s/vols/pvc-924a7cdb-6593-4a3b-b498-3fb965cc9ef6";
    fsType = "nfs";
    options = [ "nconnect=16" ];
  };
}
