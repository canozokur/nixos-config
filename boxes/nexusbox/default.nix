{ inputs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration-overrides
    inputs.nixos-hardware.nixosModules.dell-xps-15-9510
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 30; # large t/o to make sure we get a screen on boot at home
    };
    initrd = {
      luks.devices = {
        luksroot = {
          device = "/dev/disk/by-uuid/c328d3ac-cfe5-4a28-8aca-2ccdce5c18f4";
        };
      };
      availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];
    };
  };

  networking = {
    hostName = "nexusbox";
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

  # power_save:enable WiFi power management
  # so this looks like power_save=0 will disable power management
  # this is such a mess..
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
  '';

  system.stateVersion = "23.11";
}
