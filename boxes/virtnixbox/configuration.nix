{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise = {
    automatic = true;
    dates = ["03:45"];
  };
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
    initrd = {
      luks.devices = {
        luksroot = {
          device = "/dev/disk/by-uuid/3a31c2f8-b66f-4420-9444-c98cce8c1fad";
        };
      };
      availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];
    };
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

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  services.openssh.enable = true;
  system.stateVersion = "23.11";

}

