{ inputs, config, helpers, ... }:
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
            numberedAddresses // {
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
      wiredAddresses = [ "192.168.1.3/24,192.168.1.1" "192.168.0.3/24" ];
    };
    services = {
      consulServer = false;
      dnsServer = true;
      dhcpServer = true;
      galera.clusterName = "home";
    };
    nginx = {
      upstreams = {
        nzbget.servers."192.168.1.129:6789" = {};
        qbit.servers."192.168.1.129:8080" = {};
        bazarr.servers."192.168.1.129:30046" = {};
      };
      vhosts = {
        "nzbget.lan" = {
          extraConfig = ''
            client_max_body_size 0; # disable max upload size for nzbs
          '';
          listen = [{ addr = "192.168.1.253"; port = 80; }];
          locations."/" = {
            proxyPass = "http://nzbget";
            recommendedProxySettings = true;
          };
        };
        "qbit.lan" = {
          extraConfig = ''
            client_max_body_size 0; # disable max upload size for nzbs
            '';
          listen = [{ addr = "192.168.1.253"; port = 80; }];
          locations."/" = {
            proxyPass = "http://qbit";
            recommendedProxySettings = true;
          };
        };
        "bazarr.lan" = {
          extraConfig = ''
            client_max_body_size 0; # disable max upload size for nzbs
            '';
          listen = [{ addr = "192.168.1.253"; port = 80; }];
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
      { ip = "192.168.1.129"; domain = "truenas.lan"; }
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
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  system.stateVersion = "25.05";
}
