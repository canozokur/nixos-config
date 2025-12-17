{ pkgs, ... }:
{
  imports = [
    ./capabilities/desktop.nix
    ./capabilities/coding.nix
    ../programs/vencord.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
  ];
}
