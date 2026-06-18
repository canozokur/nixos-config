{ pkgs, ... }:
{
  imports = [
    ./base/desktop.nix
    ./base/coding.nix
    ../programs/vencord.nix
    ../programs/syncthing.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    tsukimi
    mangohud
  ];
}
