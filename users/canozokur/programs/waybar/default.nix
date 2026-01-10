{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  ctp-mocha = pkgs.fetchurl {
    url = "https://github.com/catppuccin/waybar/releases/download/v1.1/mocha.css";
    hash = "sha256-llnz9uTFmEiQtbfMGSyfLb4tVspKnt9Fe5lo9GbrVpE=";
  };

  swayncScript = pkgs.writeShellApplication {
    name = "swaync.sh";

    runtimeInputs = [
      pkgs.swaynotificationcenter
      pkgs.dbus
    ];

    text = ''
      readonly ENABLED='󰂜'
      readonly ENABLED_WITH_NOTIFICATIONS='󰂚'
      readonly DISABLED='󰪑'
      readonly DISABLED_WITH_NOTIFICATIONS='󰂛'
      dbus-monitor path='/org/freedesktop/Notifications',interface='org.freedesktop.Notifications',member='OnDndToggle' member='Notify' member='NotificationClosed' --profile |
        while read -r _; do
          PAUSED="$(swaync-client -D)"
          if [ "$PAUSED" == 'false' ]; then
            CLASS="enabled"
            TEXT="$ENABLED"
            COUNT="$(swaync-client -c)"
            if [ "$COUNT" != '0' ]; then
              TEXT="$ENABLED_WITH_NOTIFICATIONS"
            fi
          else
            CLASS="disabled"
            TEXT="$DISABLED"
            COUNT="$(swaync-client -c)"
            if [ "$COUNT" != '0' ]; then
              TEXT="$DISABLED_WITH_NOTIFICATIONS"
            fi
          fi
          printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
        done
    '';
  };

in
{
  xdg.configFile."waybar/ctp-mocha.css".source = ctp-mocha;

  home.packages = [ pkgs.wiremix ];

  systemd.user.services.waybar = {
    Service = {
      ExecStart = lib.mkForce "${pkgs.waybar}/bin/waybar -l error";
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "right";
        width = 20;
        spacing = 0;
        modules-center = lib.concatLists [
          (lib.optionals config.wayland.windowManager.hyprland.enable [
            "hyprland/workspaces"
            "hyprland/submap"
          ])
          (lib.optionals config.wayland.windowManager.sway.enable [
            "sway/workspaces"
            "sway/mode"
          ])
        ];
        modules-left = [
          "mpris"
        ];
        modules-right = [
          "clock"
          "tray"
          "group/hardware"
          "network"
          "pulseaudio"
          "custom/swaync"
          "battery"
        ];

        "group/hardware" = {
          orientation = "vertical";
          drawer = {
            transition-duration = 500;
            children-class = "not-power";
            transition-left-to-right = false;
          };
          modules = [
            "memory"
            "cpu"
            "temperature"
          ];
        };

        "custom/swaync" = {
          exec = "${swayncScript}/bin/swaync.sh";
          return-type = "json";
          on-click = "swaync-client -t";
          on-click-right = "swaync-client -d";
        };

        temperature = {
          hwmon-path = osConfig._meta.desktop.waybarTemperaturePath;
        };

        pulseaudio = {
          format = "{icon}";
          tooltip-format = "{desc}@%{volume}";
          format-muted = "󰸈";
          format-icons = {
            default = [
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▇"
              "█"
            ];
          };
          scroll-step = 1;
          on-click = "${pkgs.wezterm}/bin/wezterm start -- wiremix";
          on-click-right = "wpctl set-mute @DEFAULT_SINK@ toggle";
          ignored-sinks = [ "Easy Effects Sink" ];
        };

        memory = {
          interval = 30;
          format = "";
          tooltip-format = " Total: {total:0.1f}GB, Avail: {avail:0.1f}GB, Used: {used:0.1f}GB ({percentage}%)\n󰾴 Total: {swapTotal:0.1f}GB, Avail: {swapAvail:0.1f}GB, Used: {swapUsed:0.1f}GB ({swapPercentage}%)";
          max-length = 10;
        };

        tray = {
          spacing = 10;
          icon-size = 21;
        };

        clock = {
          format = "{:%H\n%M\n%S}";
          format-alt = "<span size='8pt'>{:%a\n%d\n%b\n'%y}</span>";
          justify = "right";
          interval = 1;
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          tooltip-format = "<span size='18pt'>{calendar}</span>";
        };

        network = {
          format-wifi = "{icon}";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "󰀂";
          format-alt = "󱛇";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{icon} {essid}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "󰀂  {ifname}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          interval = 5;
          nospacing = 1;
        };

        battery = {
          format = "{icon}";
          format-icons = {
            charging = [
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
            default = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          format-full = "󱟢";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
          tooltip = true;
          tooltip-format = "cap: {capacity}%\n{timeTo}\nhealth: {health}";
        };

        mpris = {
          format = "{player_icon} {dynamic}";
          ignored-players = [ "firefox" ];
          rotate = 270;
          interval = 2;
          dynamic-len = 30;
          dynamic-order = [
            "title"
            "artist"
          ];
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
        };

        "hyprland/workspaces" = {
          sort-by-name = true;
          format = "{icon}";
          on-scroll-up = "hyprctl dispatch workspace e-1";
          on-scroll-down = "hyprctl dispatch workspace e+1";
        };

        "sway/workspaces" = {
          format = "{icon}";
        };

        "hyprland/submap" = {
          format = "󰞏";
        };
      };
    };
    style = ./style.css;
  };
}
