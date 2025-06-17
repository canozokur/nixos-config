{ ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 5;
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

  time.timeZone = "Europe/Helsinki";

  hardware.graphics.enable = true;

  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  services.openssh.enable = true;
  system.stateVersion = "23.11";
}

