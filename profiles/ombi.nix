{ config, ... }:
let
  mountPoint = "/mnt/ombi-data";
  uid = config.services.ombi.user;
  gid = config.services.ombi.group;
  addr = config._meta.networks.internalIP;
  port = config.services.ombi.port;
in
{
  imports = [
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];

  services.ombi = {
    enable = true;
    openFirewall = true;
    dataDir = mountPoint;
  };

  systemd.services.ombi.unitConfig = { RequiresMountsFor = mountPoint; };

  fileSystems."${mountPoint}" = {
    device = "/dev/disk/by-uuid/33edf5bb-6439-4509-98f5-1f0a61211a41";
    fsType = "xfs";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };

  systemd.tmpfiles.rules = [
    # Type Path        Mode    UID                GID             Age  Argument
    "d ${mountPoint}   0775    ${toString uid}   ${toString gid}  -    -"
  ];

  _meta.nginx = {
    upstreams = {
      ombi = { servers."${addr}:${toString port}" = {}; };
    };
    vhosts = {
      "ombi.lan" = {
        listen = [{ addr = "192.168.1.253"; port = 80; }];
        locations = {
          "/" = {
            proxyPass = "http://ombi";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
              proxy_redirect     off;
              proxy_http_version 1.1;
              client_max_body_size 10m;
              client_body_buffer_size 128k;
              proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
              send_timeout 5m;
              proxy_read_timeout 240;
              proxy_send_timeout 240;
              proxy_connect_timeout 240;
              proxy_cache_bypass $cookie_session;
              proxy_no_cache $cookie_session;
              proxy_buffers 32 4k;
            '';
          };
        };
      };
    };
  };
}
