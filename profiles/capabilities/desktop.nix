{ lib, config, pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      zjstatus = inputs.zjstatus.packages.${prev.system}.default;
    })
  ];

  services.blueman.enable = lib.mkIf (config.hardware.bluetooth.enable == true) true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  environment.systemPackages = with pkgs; [
    greetd
    tuigreet
  ];

  environment.enableAllTerminfo = true;
  # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      };
    };
  };

  # taken from https://www.old.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  # these disables the log dumps on screen
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };


  boot.consoleLogLevel = 0;

  security.polkit.enable = true; # required for sway
  security.pam.services.swaylock = {}; # required for swaylock

  # swaync & i3status-rs requires dconf to pause notifications
  programs.dconf.enable = true;

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  services.udisks2.enable = true; # enabled for automounting
}
