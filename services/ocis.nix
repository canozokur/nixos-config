{
  pkgs,
  config,
  lib,
  mkReverseProxyService,
  ...
}:
let
  addr = config.box.networking.lanIP;
  iface = config.box.networking.lanInterface;
  mountPoint = "/mnt/ocis-data";
  uid = 328;
  gid = uid;
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  options.services.ocis.domain = lib.mkOption {
    type = lib.types.str;
    default = "files.pco.pink";
    description = "The vhost the internal reverse proxy serves this backend on.";
  };

  config = lib.mkIf config.services.ocis.enable {
    users.users.ocis.uid = lib.mkIf (config.services.ocis.user == "ocis") uid;
    users.groups.ocis.gid = lib.mkIf (config.services.ocis.group == "ocis") gid;

    fileSystems.${mountPoint} = {
      # uuid printed by `just provision-lun ocis 100G`
      device = "/dev/disk/by-uuid/223e9908-06b0-4238-ad60-96ae7df390bb";
      fsType = "ext4";
      options = [
        "nofail"
        "_netdev"
        "auto"
        "defaults"
        "X-mount.owner=${toString uid}"
        "X-mount.group=${toString gid}"
      ];
    };

    sops.secrets."ocis/admin-password" = {
      owner = "ocis";
      group = "ocis";
    };

    services.ocis = {
      package = pkgs.ocis-bin;
      address = addr;
      configDir = "${mountPoint}/config";
      stateDir = "${mountPoint}/data";
      url = "https://${config.services.ocis.domain}";
      # TLS terminates at the internal reverse proxy; OCIS_INSECURE alone does
      # not turn off the proxy's own listener TLS (PROXY_TLS defaults true)
      environment.OCIS_INSECURE = "true";
      environment.PROXY_TLS = "false";
      # web defaults to 0.0.0.0:9100, which is node-exporter's tailnet port;
      # only the proxy needs web, discovered via the internal registry
      environment.WEB_HTTP_ADDR = "${addr}:9110";
    };

    # bootstraps ocis.yaml (with its generated secrets) onto the LUN on first
    # start; an already-initialized LUN skips straight to the service
    systemd.services.ocis-init = {
      description = "oCIS first-run init";
      before = [ "ocis.service" ];
      unitConfig = {
        RequiresMountsFor = mountPoint;
        ConditionPathExists = "!${mountPoint}/config/ocis.yaml";
      };
      environment = {
        OCIS_URL = "https://${config.services.ocis.domain}";
        OCIS_BASE_DATA_PATH = "${mountPoint}/data";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "ocis";
        Group = "ocis";
        UMask = "0077";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ocis-init" ''
          ${lib.getExe pkgs.ocis-bin} init \
            --config-path ${mountPoint}/config \
            --admin-password "$(cat ${config.sops.secrets."ocis/admin-password".path})" \
            --insecure true
        '';
      };
    };

    systemd.services.ocis = {
      requires = [ "ocis-init.service" ];
      after = [ "ocis-init.service" ];
      unitConfig.RequiresMountsFor = mountPoint;
    };

    services.reverseProxy.contribs = mkReverseProxyService {
      inherit config lib;
      name = "ocis";
      domain = config.services.ocis.domain;
      inherit (config.services.ocis) port;
      websocket = true;
      # unlimited upload size, nginx default of 1M would break file sync
      locationExtraConfig = ''
        client_max_body_size 0;
      '';
      exposure = "internal";
    };

    services.consul.agentServices = [
      {
        name = "ocis";
        address = addr;
        port = config.services.ocis.port;
        checks = [
          {
            id = "ocis-check";
            name = "oCIS proxy on ${toString config.services.ocis.port}";
            tcp = "${addr}:${toString config.services.ocis.port}";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
    ];

    networking.firewall.interfaces.${iface}.allowedTCPPorts = [
      config.services.ocis.port
    ];
  };
}
