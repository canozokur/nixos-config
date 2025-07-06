{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 12;
  };

  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "${pkgs.wezterm}/bin/wezterm";
      "$launcher" = ''
        ${pkgs.rofi-wayland}/bin/rofi -combi-modes "window,drun" -show combi -modes combi \
                      -line-padding 4 -columns 2 -padding 50 -hide-scollbar \
                      -show-icons -drun-icon-theme "Arc-X-D" matching fuzzy \
                      -font "Droid Sans Regular 10"
      '';
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod SHIFT, Q, exit"
        "$mod, f, fullscreen,"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod, d, exec, $launcher"
      ];
      animations.enabled = false;
      gestures = {
        workspace_swipe = true;
      };
      cursor = {
        inactive_timeout = 10;
        hide_on_key_press = true;
      };
      ecosystem = {
        no_donation_nag = true;
        no_update_news = true;
      };
    };
  };
}
