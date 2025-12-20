{ config, pkgs, inputs, helpers, lib, ... }:
let
  isGalera = (config._meta.services.galera.clusterName != "");
  isIscsi = (config.services.openiscsi.enable == true);

  clusterName = config._meta.services.galera.clusterName;

  allHosts = inputs.self.nixosConfigurations;
  servers = helpers.getHostsWith allHosts [ "services" "galera" "clusterName" ];
  thisCluster = lib.filterAttrs (n: h:
    let
      val = lib.attrByPath [ "config" "_meta" "services" "galera" "clusterName" ] null h;
    in
      val == clusterName
  ) servers;
  galeraNodes = lib.flatten (lib.mapAttrsToList (_: h:
    "${h.config._meta.networks.internalIP}") thisCluster);
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    galeraCluster = lib.mkIf isGalera {
      enable = true;
      package = pkgs.mariadb-galera;
      nodeAddresses = galeraNodes;
      name = clusterName;
      localName = "${config.networking.hostName}";
      localAddress = "${config._meta.networks.internalIP}";
    };
  };

  services.consul.agentServices = [{
    name = "mysql";
    tags = lib.optionals isGalera ["galera-${clusterName}"] ++
      lib.optionals (config._meta.services.mysql.instanceName != "") ["instance-${config._meta.services.mysql.instanceName}"];
    address = config._meta.networks.internalIP;
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
  }];

  systemd.tmpfiles.rules = lib.optionals isIscsi [
    "D ${config.services.mysql.dataDir} 0700 mysql mysql - -"
  ];

  networking.firewall = {
    allowedTCPPorts = [
      config.services.mysql.settings.mysqld.port
      4567 # galera port
      4568 # galera ist
      4444 # galera sst
    ];
  };
}
