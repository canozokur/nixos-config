{ pkgs, ... }:
{
  imports = [
    ./capabilities/desktop.nix
    ./capabilities/coding.nix
    ../programs/vencord.nix
    ../programs/syncthing.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    tsukimi
  ];
}
