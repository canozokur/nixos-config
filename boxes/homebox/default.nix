{ config, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration-overrides
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 30; # large t/o to make sure we get a screen on boot at home
    };
  };

   networking = {
    hostName = "homebox";
    nameservers = [
      "192.168.1.1"
    ];
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.powersave = false;
      ensureProfiles = {
        secrets.entries = [
          {
            file = config.sops.secrets."network/secrets/home-wifi-5g/psk".path;
            key = "psk";
            matchId = "home-wifi-5g";
            matchSetting = "802-11-wireless-security";
            matchType = "802-11-wireless";
          }
          {
            file = config.sops.secrets."network/secrets/home-wifi/psk".path;
            key = "psk";
            matchId = "home-wifi";
            matchSetting = "802-11-wireless-security";
            matchType = "802-11-wireless";
          }
        ];
        profiles = {
          home-wifi-5g = {
            connection = {
              id = "home-wifi-5g";
              type = "wifi";
              autoconnect = true;
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "disabled";
            };
            wifi = {
              mode = "infrastructure";
              ssid = inputs.nix-secrets.network.home-wifi-5g.ssid;
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
            };
          };
          home-wifi = {
            connection = {
              id = "home-wifi";
              type = "wifi";
              autoconnect = "true";
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
          office-wifi-enterprise = {
            connection = {
              id = "office-wifi-enterprise";
              type = "wifi";
            };
            wifi = {
              mode = "infrastructure";
              ssid = inputs.nix-secrets.network.office-wifi-enterprise.ssid;
            };
            wifi-security = {
              key-mgmt = "wpa-eap";
            };
            "802-1x" = {
              eap = "peap";
              identity = "dummy";
              password = "dummy";
              phase2-auth = "mschapv2";
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
              interface-name = "eno1";
            };
          };
        };
      };
    };
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

  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  system.stateVersion = "25.05";
}
