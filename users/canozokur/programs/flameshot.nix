{ config, pkgs, ... }:
{
  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.override { enableWlrSupport = true; };
    settings = {
      General = {
        showHelp = false;
        startupLaunch = false;
        showStartupLaunchMessage = false;
        savePath = "${config.home.homeDirectory}/Pictures/screenshots";
        disabledGrimWarning = false;
      };
    };
  };
}
