{
  config,
  pkgs,
  inputs,
  helpers,
  lib,
  ...
}:
let
  isGalera = (config.services.mysql.galera.clusterName != "");

  clusterName = config.services.mysql.galera.clusterName;

  allHosts = inputs.self.nixosConfigurations;
  servers = helpers.getHostsWith allHosts [
    "services"
    "mysql"
    "galera"
    "clusterName"
  ];
  thisCluster = lib.filterAttrs (
    n: h:
    let
      val = lib.attrByPath [ "config" "services" "mysql" "galera" "clusterName" ] null h;
    in
    val == clusterName
  ) servers;
  galeraNodes = lib.flatten (
    lib.mapAttrsToList (_: h: "${h.config.box.networking.internalIP}") thisCluster
  );
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
      localAddress = "${config.box.networking.internalIP}";
    };
  };

  services.consul.agentServices = [
    {
      name = "mysql";
      tags =
        lib.optionals isGalera [ "galera-${clusterName}" ]
        ++ lib.optionals (config.services.mysql.instanceName != "") [
          "instance-${config.services.mysql.instanceName}"
        ];
      address = config.box.networking.internalIP;
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

  networking.firewall = {
    allowedTCPPorts = [
      config.services.mysql.settings.mysqld.port
    ]
    ++ lib.optionals isGalera [
      4567 # galera port
      4568 # galera ist
      4444 # galera sst
    ];
  };
}
