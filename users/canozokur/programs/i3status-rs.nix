{ ... }:
{
  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        settings = {
          font = "pango:Hack, FontAwesome 6 Free";
        };
        theme = "ctp-mocha";
        icons = "awesome6";
        blocks = [
          {
            block = "music";
            format = " $icon {$combo.str(max_w:15,rot_interval:0.5) $prev $play $next |}";
          }
          {
            block = "net";
            format = " $icon $speed_down.eng(prefix:K,w:3)/$speed_up.eng(prefix:K,w:3)";
            interval = 5;
          }
          {
            block = "docker";
            interval = 30;
            format = " $icon $running/$total";
          }
          {
            block = "cpu";
            interval = 1;
            format = " $icon $barchart $utilization ";
            format_alt = " $icon $frequency{ $boost|} ";
            info_cpu = 20;
            warning_cpu = 50;
            critical_cpu = 90;
          }
          {
            block = "load";
            interval = 5;
          }
          {
            block = "sound";
            mappings = {
              "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1" = "";
              "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2" = "";
              "alsa_output.pci-0000_01_00.1.hdmi-stereo" = "";
              "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game" = "";
              "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.mono-chat" = "";
              "alsa_output.pci-0000_00_1f.3.iec958-stereo" = "";
              "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
              "alsa_output.pci-0000_00_1f.3.pro-output-0" = "";
            };
          }
          {
            block = "time";
            interval = 1;
            format = "$icon $timestamp.datetime(f:'%a %d/%m %T')";
          }
          {
            block = "notify";
            click = [
              {
                button = "right";
                action = "show";
              }
            ];
          }
          {
            block = "battery";
            format = " $icon $percentage ";
            missing_format = "";
          }
        ];
      };
    };
  };
}
