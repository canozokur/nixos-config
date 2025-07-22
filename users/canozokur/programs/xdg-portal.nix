{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
