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
          device = "/dev/disk/by-uuid/a97e8f8a-2e6e-4dac-af71-f4e67496dfc9";
        };
      };
      availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];
    };
    kernelModules = [ "hv_vmbus" "hv_storvsc" ];
    kernelParams = [ "video=hyperv_fb:1900x1200" ];
    kernel.sysctl."vm.overcommit_memory" = 1; # https://github.com/NixOS/nix/issues/421
  };

  networking = {
    hostName = "virtnixbox";
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
            interface-name = "ens33";
          };
        };
        host_only = {
          connection = {
            id = "host-only";
            permissions = "";
            type = "802-3-ethernet";
            interface-name = "ens37";
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

