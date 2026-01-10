{
  inputs,
  config,
  helpers,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  networking = {
    hostName = "rpi01";
    networkmanager = {
      enable = true;
      dns = "default";
      wifi.powersave = false;
      ensureProfiles = {
        secrets.entries = [
          {
            file = config.sops.secrets."network/secrets/home-wifi/psk".path;
            key = "psk";
            matchId = "home-wifi";
            matchSetting = "802-11-wireless-security";
            matchType = "802-11-wireless";
          }
        ];
        profiles = {
          home-wifi = {
            connection = {
              id = "home-wifi";
              type = "wifi";
              autoconnect = "false";
            };
            wifi = {
              mode = "infrastructure";
              ssid = inputs.nix-secrets.network.home-wifi.ssid;
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
          };
          wired = {
            connection = {
              id = "wired";
              permissions = "";
              type = "802-3-ethernet";
              interface-name = "end0";
            };
            ipv4 =
              let
                ipList = config._meta.networks.wiredAddresses;
                numberedAddresses = helpers.listToNumberedAttrs "address" ipList;
              in
              numberedAddresses
              // {
                method = "manual";
                dns = "192.168.1.3";
              };
          };
        };
      };
    };
  };

  # exported metadata to use in modules
  _meta = {
    networks = {
      internalIP = "192.168.1.3";
      externalIP = "192.168.1.3";
      internalInterface = "end0";
      wiredAddresses = [
        "192.168.1.3/24,192.168.1.1"
        "192.168.0.3/24"
      ];
    };
    services = {
      consulServer = false;
      dnsServer = true;
      dhcpServer = true;
      galera.clusterName = "home";
    };
    nginx = {
      upstreams = {
        nzbget.servers."192.168.1.129:6789" = { };
        qbit.servers."192.168.1.129:8080" = { };
        bazarr.servers."192.168.1.129:30046" = { };
        emby.servers."192.168.1.129:8096" = { };
      };
      vhosts = {
        "emby.pco.pink" = {
          listen = [
            {
              addr = "192.168.1.253";
              port = 443;
              ssl = true;
            }
          ];
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
          # configuration from https://emby.media/community/index.php?/topic/93074-how-to-emby-with-nginx-with-csp-options/
          extraConfig = ''
            gzip on;
            gzip_disable "msie6";
            gzip_comp_level 6;
            gzip_min_length 1100;
            gzip_buffers 16 8k;
            gzip_proxied any;
            gzip_types
              text/plain
              text/css
              text/js
              text/xml
              text/javascript
              application/javascript
              application/x-javascript
              application/json
              application/xml
              application/rss+xml
              image/svg+xml;

            proxy_connect_timeout 1h;
            proxy_send_timeout 1h;
            proxy_read_timeout 1h;
            tcp_nodelay on;
          '';
          locations = {
            "^~ /swagger".return = 404;
            "/" = {
              proxyPass = "http://emby";
              recommendedProxySettings = true;
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $http_connection;
              '';
            };
          };
        };
        "nzbget.pco.pink" = {
          extraConfig = ''
            client_max_body_size 0; # disable max upload size for nzbs
          '';
          listen = [
            {
              addr = "192.168.1.253";
              port = 443;
              ssl = true;
            }
          ];
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://nzbget";
            recommendedProxySettings = true;
          };
        };
        "qbit.pco.pink" = {
          extraConfig = ''
            client_max_body_size 0; # disable max upload size for nzbs
          '';
          listen = [
            {
              addr = "192.168.1.253";
              port = 443;
              ssl = true;
            }
          ];
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://qbit";
            recommendedProxySettings = true;
          };
        };
        "bazarr.pco.pink" = {
          extraConfig = ''
            client_max_body_size 0; # disable max upload size for nzbs
          '';
          listen = [
            {
              addr = "192.168.1.253";
              port = 443;
              ssl = true;
            }
          ];
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://bazarr";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection $http_connection;
              proxy_redirect     off;
              proxy_http_version 1.1;
            '';
          };
        };
      };
    };
    # static IP configurations, defined here to prevent double entries
    dnsConfigurations = [
      {
        ip = "192.168.1.129";
        domain = "truenas.lan";
      }
    ];
  };

  hardware.graphics.enable = true;
  # bluetooth config
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General = {
    FastConnectable = true;
    Experimental = true;
    KernelExperimental = true;
  };
  hardware.bluetooth.powerOnBoot = true;
  # nixos-hardware options
  hardware.raspberry-pi."4" = {
    bluetooth.enable = true;
    fkms-3d.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  system.stateVersion = "25.05";
}
