{ pkgs, lib, ... }:
let
  ctp-mocha = pkgs.fetchurl {
    url = "https://github.com/catppuccin/waybar/releases/download/v1.1/mocha.css";
    hash = "sha256-llnz9uTFmEiQtbfMGSyfLb4tVspKnt9Fe5lo9GbrVpE=";
  };
in
{
  xdg.configFile."waybar/ctp-mocha.css".source = ctp-mocha;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "right";
        width = 20;
        spacing = 0;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/submap"
        ];
        modules-center = [
          "mpris"
        ];
        modules-right = [
          "clock"
          "tray"
          "group/hardware"
          "network"
          "wireplumber"
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

        temperature = {
          hwmon-path = lib.mkDefault "";
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
          format-alt = "{:%a\n%d\n%b\n'%y}";
          justify = "right";
          interval = 1;
          tooltip-format = "<span size='18pt'>{calendar}</span>";
        };

        network = {
          format-wifi = "{icon}";
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
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
          format = "{capacity}% {icon}";
          format-icons = {
            charging = [
              "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"
            ];
            default = [
              "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"
            ];
          };
          format-full = "󱟢";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
          tooltip = false;
        };

        mpris = {
          format = "{player_icon} {dynamic}";
          ignored-players = [ "firefox" ];
          rotate = 270;
          interval = 2;
          dynamic-len = 30;
          dynamic-order = [ "title" "artist" ];
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = { paused = "⏸"; };
        };

        "hyprland/workspaces" = {
          sort-by-name = true;
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
