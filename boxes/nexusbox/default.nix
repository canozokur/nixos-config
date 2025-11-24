{ inputs, ... }:
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
    nameservers = [
      "192.168.50.2"
    ];
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.powersave = false;
      ensureProfiles.profiles = {
        wired = {
          connection = {
            id = "wired";
            permissions = "";
            type = "802-3-ethernet";
            interface-name = "enp0s13f0u3u1c2";
          };
        };
      };
    };
  };

  hardware.graphics.enable = true;
  # bluetooth config
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.FastConnectable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  # power_save=true actually disables power saving config for some reason
  # and power_level=5 should max it out (hopefully?)
  # for power_scheme explanation see:
  # https://wiki.debian.org/iwlwifi#WiFi interruptions on Intel AX
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=true power_level=5
    options iwlmvm power_scheme=1
  '';

  system.stateVersion = "23.11";
}
