{ config, lib, mkReverseProxyService, ... }:
let
  port = config.services.radarr.settings.server.port;
  mountPoint = "/mnt/radarr-data";
  uid = config.ids.uids.radarr;
  gid = 568;
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "radarr";
    subdomain = "radarr";
    inherit port;
    websocket = true;
  };

  users.groups = {
    media = { inherit gid; };
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    dataDir = mountPoint;
  };

  systemd.services.radarr = {
    unitConfig.RequiresMountsFor = mountPoint;
    serviceConfig.UMask = lib.mkForce 0002;
  };

  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/1c44502d-eda8-4c27-9bac-b891618f52bf";
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

  # using mkDefault because other services might mount the same thing
  fileSystems."/shared" = lib.mkDefault {
    device = "192.168.0.100:/mnt/main/k8s/vols/pvc-924a7cdb-6593-4a3b-b498-3fb965cc9ef6";
    fsType = "nfs";
    options = [ "nconnect=16" ];
  };
}
