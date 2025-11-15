{ ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 30; # large t/o to make sure we get a screen on boot at home
    };
    initrd = {
      luks.devices = {
        "luks-5727599b-0858-4f2f-ba0c-9ca9f8921758" = {
          device = "/dev/disk/by-uuid/5727599b-0858-4f2f-ba0c-9ca9f8921758";
        };
        "luks-e0761007-487f-448c-a637-1db4be9f46d9" = {
          device = "/dev/disk/by-uuid/e0761007-487f-448c-a637-1db4be9f46d9";
        };
      };
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
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

  time.timeZone = "Europe/Helsinki";

  hardware.graphics.enable = true;
  # bluetooth config
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.FastConnectable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  # don't go to sleep on lid events
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  services.openssh.enable = true;
  system.stateVersion = "25.05";
}

