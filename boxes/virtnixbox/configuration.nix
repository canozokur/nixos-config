{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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

  networking.hostName = "virtnixbox";
  time.timeZone = "Europe/Helsinki";

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  services.openssh.enable = true;
  system.stateVersion = "23.11";

}

