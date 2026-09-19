{
  config,
  pkgs,
  lib,
  ...
}:
let
  # TODO: maybe make this configurable?
  mountPoint = "/var/lib/mysql";
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    # level 2 (default) logs consul's tcp checks as aborted connections
    settings.mysqld.log_warnings = 1;
  };

  services.consul.agentServices = [
    {
      name = "mysql";
      tags = lib.optionals (config.services.mysql.instanceName != "") [
        "instance-${config.services.mysql.instanceName}"
      ];
      address = config.box.networking.lanIP;
      port = config.services.mysql.settings.mysqld.port;
      checks = [
        {
          id = "mysql-check";
          name = "MySQL on port ${toString config.services.mysql.settings.mysqld.port}";
          tcp = "localhost:${toString config.services.mysql.settings.mysqld.port}";
          interval = "10s";
          timeout = "1s";
        }
      ];
    }
  ];

  networking.firewall.allowedTCPPorts = [
    config.services.mysql.settings.mysqld.port
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
