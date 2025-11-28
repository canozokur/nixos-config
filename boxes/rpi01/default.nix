{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  networking = {
    hostName = "rpi01";
    nameservers = [
      "192.168.1.1"
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
            interface-name = "eno1";
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
