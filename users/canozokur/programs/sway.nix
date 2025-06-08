{ pkgs, ... }:
{
  services.gnome-keyring.enable = true; # enable a keyring provider
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.ghostty}/bin/ghostty";
      fonts = {
        names = ["Droid Sans"];
        style = "Regular";
        size = "8";
      };

      startup = [
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --primary --watch wl-copy"; always = true; }
      ];
    };
    extraConfig = ''
      default_border pixel 10
    '';
  };

  home.packages = [
    pkgs.wl-clipboard
  ];
}

