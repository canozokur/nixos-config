{ pkgs, pkgsFast, ... }:
{
  imports = [
    ./base/desktop.nix
    ./base/coding.nix
    ../programs/vencord.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    pkgsFast.plezy
    mangohud
  ];
}
