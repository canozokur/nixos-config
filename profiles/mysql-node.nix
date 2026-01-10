{ config, ... }:
let
  mountPoint = "/var/lib/mysql";
in
{
  imports = [
    ./capabilities/mysql.nix
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/0a4ed9a9-c4cd-49bf-93d3-132d11d684e6";
    fsType = "xfs";
    options = [
      "nofail"
      "_netdev"
      "auto"
      "exec"
      "defaults"
      "X-mount.owner=${toString config.services.mysql.user}"
      "X-mount.group=${toString config.services.mysql.group}"
    ];
  };

  systemd.services.mysql.unitConfig.RequiresMountsFor = mountPoint;
}
