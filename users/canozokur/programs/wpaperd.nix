{ config, ... }:
{
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        duration = "15m";
        mode = "center";
        path = "${config.home.homeDirectory}/Pictures/Desktoppr";
      };
    };
  };
}
