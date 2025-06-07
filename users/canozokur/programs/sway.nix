{ pkgs, ... }:
{
  services.gnome-keyring.enable = true; # enable a keyring provider
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.ghostty}/bin/ghostty";
    };
  };
}

