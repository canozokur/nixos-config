{ lib, ... }:
{
  config.hostSpecificOverrides = {
    wayland.windowManager.hyprland.settings = lib.mkMerge [
      # use iGPU first
      { env = [ "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0" ]; }
    ];
  };
}
