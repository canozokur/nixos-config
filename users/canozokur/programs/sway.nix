{ pkgs, lib, ... }:
{
  services.gnome-keyring.enable = true; # enable a keyring provider
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "${pkgs.ghostty}/bin/ghostty";
      fonts = {
        names = ["Droid Sans"];
        style = "Regular";
        size = "8";
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+q" = "kill";
        "${modifier}+d" = ''
          exec ${pkgs.rofi}/bin/rofi -combi-modi "window#drun" -show combi -modi combi \
                -line-padding 4 -columns 2 -padding 50 -hide-scrollbar \
                -show-icons -drun-icon-theme "Arc-X-D" -matching fuzzy \
                -font "Droid Sans Regular 10"
        '';
        "${modifier}+Shift+r" = "reload";
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

