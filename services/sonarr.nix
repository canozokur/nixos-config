{
  config,
  lib,
  constants,
  mkReverseProxyService,
  ...
}:
let
  port = config.services.sonarr.settings.server.port;
  mountPoint = "/mnt/sonarr-data";
  uid = config.ids.uids.sonarr;
  gid = 568;
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "sonarr";
    subdomain = "sonarr";
    inherit port;
    websocket = true;
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
