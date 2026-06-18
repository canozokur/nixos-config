{
  config,
  lib,
  pkgs,
  ...
}:
let
  vd = config.services.virtualDisplay;
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  # these are envvars available within Sunshine, a list can be found in Sunshine's Application config page
  virtualDisplaySpec = "\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS}";
  prepDoScript = pkgs.writeShellScriptBin "prepSunshine" ''
    ${hyprctl} output create headless ${vd.outputName}
    ${hyprctl} eval 'hl.monitor({output="${vd.outputName}",mode="${virtualDisplaySpec}",position="0x0",scale=1,})'
  '';
  prepUndoScript = pkgs.writeShellScriptBin "unprepSunshine" ''
    ${hyprctl} output remove ${vd.outputName}
  '';
in
{
  options.services.virtualDisplay = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Create a virtual headless display for streaming on this host";
        outputName = lib.mkOption {
          type = lib.types.str;
          default = "CUSTOM-HEADLESS-1";
          description = "Headless output name handed to Sunshine's output_name.";
        };
      };
    };
    default = { };
    description = "Virtual headless display used by Sunshine and any streaming setup.";
  };

  options.services.sunshine.capture = lib.mkOption {
    type = lib.types.enum [
      "wlr"
      "kms"
    ];
    default = "wlr";
    description = ''
      Sunshine capture method. `wlr` (default) works with Hyprland's headless
      output and needs no extra capability. `kms` captures the DRM/KMS
      framebuffer and requires cap_sys_admin on the sunshine binary.
    '';
  };

  config = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = config.services.sunshine.capture == "kms";
      openFirewall = true;
      package = pkgs.sunshine.override {
        boost = pkgs.boost187;
      };
      settings = lib.mkIf vd.enable {
        # output_name does not work right now, track here for the PR to land:
        # https://nixpk.gs/pr-tracker.html?pr=521906
        output_name = vd.outputName;
        capture = config.services.sunshine.capture;
      };
      applications = {
        apps = [
          {
            name = "Desktop";
            cmd = "";
            prep-cmd = lib.optionals (vd.enable == true) [
              {
                do = lib.getExe prepDoScript;
                undo = lib.getExe prepUndoScript;
              }
            ];
            auto-detach = "true";
          }
        ];
      };
    };
  };
}
