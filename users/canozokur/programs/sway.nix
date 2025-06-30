{ pkgs, ... }:
let
  satty = ''
    ${pkgs.satty}/bin/satty -f - --initial-tool=arrow \
      --copy-command=wl-copy --actions-on-escape="save-to-clipboard,exit" \
      --brush-smooth-history-size=5 --disable-notifications
  '';
in
{

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 12;
  };

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
      window = {
        border = 3; # titlebar config will decide if this is normal or pixel
        titlebar = false; # pixel if false, normal if true
      };
      workspaceAutoBackAndForth = true;
      floating = {
        modifier = modifier;
        criteria = [
          { window_type = "dialog"; }
          { window_type = "menu"; }
          { window_role = "dialog"; }
          { window_role = "pop-up"; }
          { window_role = "bubble"; }
        ];
      };

      seat = {
        "*" = {
          hide_cursor = "when-typing enable";
        };
      };

      bars = [
        {
          fonts = {
            names = [ "CaskaydiaCove NF" "Font Awesome 6 Free" ];
            size = "10";
          };
          position = "bottom";
          trayOutput = "*";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
        }
      ];

      modes = {
        screenshot = {
          r = ''exec swaymsg 'mode "default"' && ${pkgs.grim}/bin/grim -t ppm -g "$(${pkgs.slurp}/bin/slurp -d)" - | ${satty}'';
          f = ''exec swaymsg 'mode "default"' && grim -t ppm - | ${satty}'';
          w = ''exec swaymsg 'mode "default"' && swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -t ppm -g - - | ${satty}'';
          Return = "mode default";
          Escape = "mode default";
        };
      };

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+q" = "kill";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+q" = "exec swaynag -t warning -m 'Really exit?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+r" = "mode 'resize'";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+shift+y" = "exec ${pkgs.swaylock}/bin/swaylock -f -c 000000";
        "${modifier}+b" = "split h";
        "${modifier}+v" = "split v";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout split";
        "${modifier}+shift+space" = "floating toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+1" = "workspace 1";
        "${modifier}+2" = "workspace 2";
        "${modifier}+3" = "workspace 3";
        "${modifier}+4" = "workspace 4";
        "${modifier}+5" = "workspace 5";
        "${modifier}+6" = "workspace 6";
        "${modifier}+7" = "workspace 7";
        "${modifier}+8" = "workspace 8";
        "${modifier}+9" = "workspace 9";
        "${modifier}+Shift+1" = "move container to workspace 1";
        "${modifier}+Shift+2" = "move container to workspace 2";
        "${modifier}+Shift+3" = "move container to workspace 3";
        "${modifier}+Shift+4" = "move container to workspace 4";
        "${modifier}+Shift+5" = "move container to workspace 5";
        "${modifier}+Shift+6" = "move container to workspace 6";
        "${modifier}+Shift+7" = "move container to workspace 7";
        "${modifier}+Shift+8" = "move container to workspace 8";
        "${modifier}+Shift+9" = "move container to workspace 9";
        "${modifier}+minus" = "scratchpad show";
        "${modifier}+Shift+minus" = "floating enable, resize set width 1366 height 675, move container to scratchpad";
        "${modifier}+Shift+p" = "mode screenshot";



        "${modifier}+d" = ''
          exec rofi -combi-modes "window#drun" -show combi -modes combi \
                  -line-padding 4 -columns 2 -padding 50 -hide-scrollbar \
                  -show-icons -drun-icon-theme "Arc-X-D" -matching fuzzy \
                  -font "Droid Sans Regular 10"
        '';
        "${modifier}+shift+e" = ''
          exec cliphist list | rofi -dmenu -drun-icon-theme "Arc-X-D" \
                  -font "Droid Sans Regular 10" -display-columns 2 | cliphist decode \
                  | wl-copy
        '';
      };

      startup = [
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store"; }
      ];
    };
  };

  home.packages = [
    pkgs.wl-clipboard
  ];
}

