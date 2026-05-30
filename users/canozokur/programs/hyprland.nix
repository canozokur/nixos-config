{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  mod = "SUPER";
  terminal = "${pkgs.wezterm}/bin/wezterm";
  launcher = "${pkgs.rofi}/bin/rofi -show-icons -matching fuzzy";

  mkBind = keys: action: flags: {
    _args = [
      keys
      (lib.generators.mkLuaInline action)
    ]
    ++ lib.optional (flags != { }) flags;
  };

  mkExec = keys: cmd: mkBind keys "hl.dsp.exec_cmd([[${cmd}]])" { };
  mkExecFlags =
    keys: cmd: flags:
    mkBind keys "hl.dsp.exec_cmd([[${cmd}]])" flags;
in
{
  home.packages = [
    pkgs.wl-clipboard
  ];

  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    submaps = {
      resize = {
        onDispatch = "";
        settings = {
          bind = [
            (mkBind "h" "hl.dsp.window.resize({ x = -10, y = 0, relative = true })" { repeating = true; })
            (mkBind "l" "hl.dsp.window.resize({ x = 10, y = 0, relative = true })" { repeating = true; })
            (mkBind "j" "hl.dsp.window.resize({ x = 0, y = 10, relative = true })" { repeating = true; })
            (mkBind "k" "hl.dsp.window.resize({ x = 0, y = -10, relative = true })" { repeating = true; })

            (mkBind "SHIFT + h" "hl.dsp.window.resize({ x = -30, y = 0, relative = true })" {
              repeating = true;
            })
            (mkBind "SHIFT + l" "hl.dsp.window.resize({ x = 30, y = 0, relative = true })" {
              repeating = true;
            })
            (mkBind "SHIFT + j" "hl.dsp.window.resize({ x = 0, y = 30, relative = true })" {
              repeating = true;
            })
            (mkBind "SHIFT + k" "hl.dsp.window.resize({ x = 0, y = -30, relative = true })" {
              repeating = true;
            })

            (mkBind "escape" ''hl.dsp.submap("reset")'' { })
            (mkBind "Return" ''hl.dsp.submap("reset")'' { })
            (mkBind "${mod} + r" ''hl.dsp.submap("reset")'' { })
          ];
        };
      };

      screenshot =
        let
          satty = "${pkgs.satty}/bin/satty -f - --initial-tool=arrow --copy-command=wl-copy --actions-on-escape=\"save-to-clipboard,exit\" --brush-smooth-history-size=5 --disable-notifications";
        in
        {
          onDispatch = "";
          settings = {
            bind = [
              (mkExecFlags "r" "${pkgs.grim}/bin/grim -t ppm -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${satty}" {
                bypass = true;
              })
              (mkBind "r" ''hl.dsp.submap("reset")'' { bypass = true; })

              (mkExecFlags "f" "${pkgs.grim}/bin/grim -t ppm - | ${satty}" { bypass = true; })
              (mkBind "f" ''hl.dsp.submap("reset")'' { bypass = true; })

              (mkExecFlags "w"
                "hyprctl activewindow -j | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' | grim -t ppm -g - - | ${satty}"
                { bypass = true; }
              )
              (mkBind "w" ''hl.dsp.submap("reset")'' { bypass = true; })

              (mkBind "Return" ''hl.dsp.submap("reset")'' { })
              (mkBind "escape" ''hl.dsp.submap("reset")'' { })
            ];
          };
        };
    };

    settings = {
      config = {
        general.layout = "dwindle";
        master = {
          orientation = "center";
          slave_count_for_center_master = 0;
          smart_resizing = false;
        };

        animations.enabled = false;

        binds = {
          workspace_back_and_forth = true;
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
      };

      bind = [
        (mkExec "${mod} + Return" terminal)
        (mkBind "${mod} + q" "hl.dsp.window.close()" { })
        (mkBind "${mod} + SHIFT + q" "hl.dsp.exit()" { })

        (mkBind "${mod} + f" ''hl.dsp.window.fullscreen({ mode = "maximized" })'' { })
        (mkBind "${mod} + SHIFT + f" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'' { })

        # Move focus
        (mkBind "${mod} + h" ''hl.dsp.focus({ direction = "l" })'' { })
        (mkBind "${mod} + l" ''hl.dsp.focus({ direction = "r" })'' { })
        (mkBind "${mod} + k" ''hl.dsp.focus({ direction = "u" })'' { })
        (mkBind "${mod} + j" ''hl.dsp.focus({ direction = "d" })'' { })

        # Move window
        (mkBind "${mod} + SHIFT + h" ''hl.dsp.window.move({ direction = "l" })'' { })
        (mkBind "${mod} + SHIFT + l" ''hl.dsp.window.move({ direction = "r" })'' { })
        (mkBind "${mod} + SHIFT + k" ''hl.dsp.window.move({ direction = "u" })'' { })
        (mkBind "${mod} + SHIFT + j" ''hl.dsp.window.move({ direction = "d" })'' { })

        # Switch to workspace
        (mkBind "${mod} + 1" ''hl.dsp.focus({ workspace = "1" })'' { })
        (mkBind "${mod} + 2" ''hl.dsp.focus({ workspace = "2" })'' { })
        (mkBind "${mod} + 3" ''hl.dsp.focus({ workspace = "3" })'' { })
        (mkBind "${mod} + 4" ''hl.dsp.focus({ workspace = "4" })'' { })
        (mkBind "${mod} + 5" ''hl.dsp.focus({ workspace = "5" })'' { })
        (mkBind "${mod} + 6" ''hl.dsp.focus({ workspace = "6" })'' { })
        (mkBind "${mod} + 7" ''hl.dsp.focus({ workspace = "7" })'' { })
        (mkBind "${mod} + 8" ''hl.dsp.focus({ workspace = "8" })'' { })
        (mkBind "${mod} + 9" ''hl.dsp.focus({ workspace = "9" })'' { })

        # Move active window to a workspace
        (mkBind "${mod} + SHIFT + 1" ''hl.dsp.window.move({ workspace = "1" })'' { })
        (mkBind "${mod} + SHIFT + 2" ''hl.dsp.window.move({ workspace = "2" })'' { })
        (mkBind "${mod} + SHIFT + 3" ''hl.dsp.window.move({ workspace = "3" })'' { })
        (mkBind "${mod} + SHIFT + 4" ''hl.dsp.window.move({ workspace = "4" })'' { })
        (mkBind "${mod} + SHIFT + 5" ''hl.dsp.window.move({ workspace = "5" })'' { })
        (mkBind "${mod} + SHIFT + 6" ''hl.dsp.window.move({ workspace = "6" })'' { })
        (mkBind "${mod} + SHIFT + 7" ''hl.dsp.window.move({ workspace = "7" })'' { })
        (mkBind "${mod} + SHIFT + 8" ''hl.dsp.window.move({ workspace = "8" })'' { })
        (mkBind "${mod} + SHIFT + 9" ''hl.dsp.window.move({ workspace = "9" })'' { })

        (mkExec "${mod} + d" "${launcher} -combi-modes \"window,drun\" -show combi -modes combi -columns 2")
        (mkExec "${mod} + SHIFT + e" "cliphist list | ${launcher} -dmenu -display-columns 2 | cliphist decode | wl-copy")
        (mkExec "${mod} + SHIFT + 0" "hyprlock")

        (mkBind "${mod} + r" ''hl.dsp.submap("resize")'' { })
        (mkBind "${mod} + SHIFT + p" ''hl.dsp.submap("screenshot")'' { })

        # Mouse window controls
        (mkBind "${mod} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (mkBind "${mod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

        # Media keys
        (mkExecFlags "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" { locked = true; })
        (mkExecFlags "XF86AudioPlay" "playerctl play-pause" { locked = true; })
        (mkExecFlags "XF86AudioNext" "playerctl next" { locked = true; })
        (mkExecFlags "XF86AudioPrev" "playerctl previous" { locked = true; })
      ];

      layer_rule = [
        {
          match = {
            namespace = "waybar";
          };
          blur = true;
        }
      ];

      window_rule = [
        {
          match = {
            class = "^(Zoom.*)";
            title = "^(meeting bottombar.*)$";
          };
          stay_focused = true;
        }
        {
          match = {
            class = "^(Zoom.*)";
          };
          float = true;
        }
        {
          match = {
            fullscreen = true;
          };
          border_color = "rgb(50fa7b)";
        }
      ];

      workspace_rule = [
        {
          workspace = "1";
          layout_opts = {
            orientation = "left";
          };
        }
      ];

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      env = map (item: {
        _args = lib.splitString "," item;
      }) osConfig._meta.desktop.hyprlandGPU;
    };
  };
}
