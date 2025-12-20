{ inputs, config, lib, ... }:
let
  isIscsi = (config.services.openiscsi.enable == true);
in
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
            ipv4 = {
              method = "manual";
              address1 = "192.168.1.3/24,192.168.1.1";
              address2 = "192.168.0.3/24";
              dns = "127.0.0.1";
            };
          };
        };
      };
    };
  };

  fileSystems."/var/lib/mysql" = lib.mkIf isIscsi {
    device = "/dev/disk/by-uuid/bb1c3289-d975-4cd7-81ba-32568114c200";
    fsType = "xfs";
    options = [ "nofail" "_netdev" "auto" "exec" "defaults"];
  };

  # exported metadata to use in modules
  _meta = {
    networks = {
      internalIP = "192.168.1.3";
      externalIP = "192.168.1.3";
      internalInterface = "end0";
    };
    services = {
      consulServer = false;
      dnsServer = true;
      dhcpServer = true;
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
