{ pkgs, ... }:
{
  home.packages = [
    pkgs.wl-clipboard
  ];

  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    # until this or something adjacent has merged https://github.com/nix-community/home-manager/pull/7277
    # we should keep extraConfig for now
    extraConfig = ''
      # window resize
      bind = $mod, r, submap, resize
      submap = resize
      binde = , h, resizeactive, -10 0
      binde = , l, resizeactive, 10 0
      binde = , j, resizeactive, 0 10
      binde = , k, resizeactive, 0 -10
      binde = SHIFT, h, resizeactive, -30 0
      binde = SHIFT, l, resizeactive, 30 0
      binde = SHIFT, j, resizeactive, 0 30
      binde = SHIFT, k, resizeactive, 0 -30
      bind = , escape, submap, reset
      bind = , Return, submap, reset
      bind = $mod, r, submap, reset
      submap = reset

      # screenshot
      $satty = ${pkgs.satty}/bin/satty -f - --initial-tool=arrow \
                --copy-command=wl-copy --actions-on-escape="save-to-clipboard,exit" \
                --brush-smooth-history-size=5 --disable-notifications
      bind = $mod SHIFT, p, submap, screenshot
      submap = screenshot
      bindp = , r, exec, ${pkgs.grim}/bin/grim -t ppm -g "$(${pkgs.slurp}/bin/slurp -d)" - | $satty
      bindp = , r, submap, reset
      bindp = , f, exec, ${pkgs.grim}/bin/grim -t ppm - | $satty
      bindp = , f, submap, reset
      bindp = , w, exec, hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -t ppm -g - - | $satty
      bindp = , w, submap, reset
      bind = , Return, submap, reset
      bind = , Escape, submap, reset
      submap = reset
    '';
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "${pkgs.wezterm}/bin/wezterm";
      "$launcher" = "${pkgs.rofi-wayland}/bin/rofi -show-icons -matching fuzzy";
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, q, killactive,"
        "$mod SHIFT, q, exit"
        "$mod, f, fullscreen,"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"
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
        "$mod, d, exec, $launcher -combi-modes \"window,drun\" -show combi -modes combi -columns 2"
        "$mod SHIFT, e, exec, cliphist list | $launcher -dmenu -display-columns 2 | cliphist decode | wl-copy"
        "$mod SHIFT, 0, exec, hyprlock"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      layerrule = [
        "blur, waybar"
      ];
      windowrule = [
        "stayfocused, class:zoom, title:menu window"
      ];
      binds = {
        workspace_back_and_forth = true;
      };
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
      decoration = {
        blur = {
          enabled = true;
          size = 6;
          passes = 1;
          new_optimizations = true;
        };
      };
      render = {
        # wpaperd and hyprland does not agree on vertical screens
        # https://github.com/hyprwm/Hyprland/issues/9408#issuecomment-2661608482
        expand_undersized_textures = false;
      };
    };
  };
}
