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
              autoconnect = false;
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
              interface-name = "eno1";
            };
          };
        };
      };
    };
  };

  _meta = {
    networks = {
      internalInterface = "eno1";
    };
    services = {
      consulServer = false;
    };
    desktop = {
      hyprlandGPU = [ "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0" ];
      waybarTemperaturePath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input";
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
