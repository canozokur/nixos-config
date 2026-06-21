{ config, lib, mkReverseProxyService, ... }:
let
  mountPoint = "/mnt/syncthing-data";
  uid = config.services.syncthing.user;
  gid = config.services.syncthing.group;
  iface = config.box.networking.internalInterface;
  addr = config.box.networking.internalIP;
  port = 8384;
in
{
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

  systemd.services.syncthing.unitConfig = {
    RequiresMountsFor = mountPoint;
  };

  sops.secrets."syncthing/gui" = {
    owner = uid;
    group = gid;
  };

  services.syncthing = {
    enable = true;
    dataDir = mountPoint;
    openDefaultPorts = true;
    # since this is shared with non-nixos users I cba to declare everything here
    # maybe someday..
    overrideFolders = false;
    overrideDevices = false;
    guiPasswordFile = config.sops.secrets."syncthing/gui".path;
    guiAddress = "${addr}:${toString port}";
    settings = {
      gui = {
        enabled = true;
        user = "admin";
      };
      # to get all the options we can use this (and get the apikey from syncthing's settings if needed)
      # curl -H "X-API-Key: <apikey>" -X GET http://ip.add.re.ss:8384/rest/config
      options = {
        listenAddresses =
          let
            uri = "${addr}:22000";
          in
          [
            "quic://${uri}"
            "tcp://${uri}"
          ];
        urAccepted = -1;
      };
    };
  };

  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "syncthing";
    domain = "sync.pco.pink";
    port = 8384;
    listenAddr = "192.168.1.254";
    locationExtraConfig = ''
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
    '';
  };

  networking.firewall.interfaces.${iface} = {
    allowedTCPPorts = [ 8384 ]; # gui port
  };
}
