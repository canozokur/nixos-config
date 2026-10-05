{ pkgs, ... }:
{
  programs.steam.package = pkgs.steam.override {
    extraEnv = {
      DRI_PRIME = "pci-0000_03_00_0";
      MESA_VK_DEVICE_SELECT = "1002:744c";
    };
  };
}
