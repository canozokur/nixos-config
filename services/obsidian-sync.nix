{
  config,
  lib,
  mkReverseProxyService,
  ...
}:
let
  addr = config.box.networking.lanIP;
  iface = config.box.networking.lanInterface;
  uid = config.ids.uids.couchdb;
  gid = config.ids.gids.couchdb;
in
{
  options.services.obsidianSync = {
    enable = lib.mkEnableOption "Obsidian Self-hosted LiveSync backend (CouchDB).";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5984;
      description = "CouchDB listen port.";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "obsidian-sync.pco.pink";
      description = "The vhost the internal reverse proxy serves this backend on.";
    };
  };

  config = lib.mkIf config.services.obsidianSync.enable {
    fileSystems."/mnt/obsidian-data" = {
      device = "/dev/disk/by-uuid/885e174e-74be-4b6e-a540-4de6191d219e";
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

    sops.secrets."obsidian-sync/couchdb" = {
      owner = "couchdb";
      group = "couchdb";
    };

    services.couchdb = {
      enable = true;
      # admin credentials come from sops
      adminPass = null;
      bindAddress = addr;
      inherit (config.services.obsidianSync) port;
      databaseDir = "/mnt/obsidian-data";
      viewIndexDir = "/mnt/obsidian-data";
      # default is /var/lib/couchdb/local.ini, whose parent dir the module
      # only creates when databaseDir is /var/lib/couchdb - keep all state
      # on the LUN instead.
      # NOTE: local.ini loads AFTER extraConfigFiles, so its persisted admin
      # hash shadows the sops plaintext. Password rotation = delete the
      # [admins] section from local.ini, then restart couchdb.
      configFile = "/mnt/obsidian-data/local.ini";
      extraConfig = {
        couchdb.single_node = true;
        chttpd.require_valid_user = true;
        # dedicated, non-authenticated metrics listener. Bind all interfaces
        # and let the firewall restrict it to the tailnet (node-exporter
        # pattern), so prometheus can discover it via consul.
        prometheus = {
          additional_port = true;
          bind_address = "any";
          port = 17986;
        };
        cors = {
          credentials = true;
          # exact origins/headers required by obsidian-livesync
          origins = "app://obsidian.md,capacitor://localhost,http://localhost";
          headers = "accept, authorization, content-type, origin, referer, x-custom-header";
        };
      };
      extraConfigFiles = [ config.sops.secrets."obsidian-sync/couchdb".path ];
    };

    systemd.services.couchdb.unitConfig.RequiresMountsFor = "/mnt/obsidian-data";

    services.reverseProxy.contribs = mkReverseProxyService {
      inherit config lib;
      name = "obsidian-sync";
      domain = config.services.obsidianSync.domain;
      inherit (config.services.obsidianSync) port;
      # obsidian-livesync requirements
      locationExtraConfig = ''
        proxy_buffering off;
        client_max_body_size 50M;
      '';
      exposure = "internal";
    };

    services.consul.agentServices = [
      {
        name = "obsidian-sync";
        address = addr;
        port = config.services.obsidianSync.port;
        checks = [
          {
            id = "obsidian-sync-check";
            name = "CouchDB on ${toString config.services.obsidianSync.port}";
            tcp = "${addr}:${toString config.services.obsidianSync.port}";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
      {
        # no address, agent registers on tailscale addr so everything stays there
        name = "obsidian-sync-metrics";
        port = 17986;
        checks = [
          {
            id = "obsidian-sync-metrics-check";
            name = "CouchDB metrics on port 17986";
            http = "http://localhost:17986/_node/couchdb@127.0.0.1/_prometheus";
            interval = "10s";
            timeout = "2s";
          }
        ];
      }
    ];

    networking.firewall.interfaces = {
      ${iface}.allowedTCPPorts = [ config.services.obsidianSync.port ];
      ${config.box.networking.tailnet.interface}.allowedTCPPorts = [ 17986 ];
    };
  };
}
