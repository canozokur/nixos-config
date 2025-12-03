{ pkgs, ... }:
{
  imports = [
    ../programs/vencord.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
  ];
}
