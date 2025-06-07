{ ... }:
{
  services.gnome-keyring.enable = true; # enable a keyring provider
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
    };
  };
}

