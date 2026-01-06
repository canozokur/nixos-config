{ config, ... }:
let
  mountPoint = "/mnt/syncthing-data";
  uid = config.services.syncthing.user;
  gid = config.services.syncthing.group;
  iface = config._meta.networks.internalInterface;
  addr = config._meta.networks.internalIP;
  port = 8384;
in
{
  imports = [
  ];


  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/4464b8f3-9551-40cb-879d-b12170ad1c59";
    fsType = "xfs";
    options = [
      "X-mount.owner=${toString uid}"
      "X-mount.group=${toString gid}"
      "nofail"
      "_netdev"
      "auto"
      "exec"
      "defaults"
    ];
  };

  systemd.services.syncthing.unitConfig = { RequiresMountsFor = mountPoint; };

  sops.secrets."syncthing/gui" = {
    owner = uid;
    group = gid;
  };

  services.syncthing = {
    enable = true;
    dataDir = mountPoint;
    openDefaultPorts = true;
    guiPasswordFile = config.sops.secrets."syncthing/gui".path;
    guiAddress = "${addr}:${toString port}";
    settings = {
      gui = {
        enabled = true;
        user = "admin";
      };
    };
  };

  _meta.nginx = {
    upstreams = {
      syncthing = { servers."${addr}:${toString port}" = {}; };
    };
    vhosts = {
      "sync.pco.pink" = {
        listen = [{ addr = "192.168.1.254"; port = 443; ssl = true; }];
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://syncthing";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };
      };
    };
  };

  networking.firewall.interfaces.${iface} = {
    allowedTCPPorts = [ 8384 ]; # gui port
  };
}
