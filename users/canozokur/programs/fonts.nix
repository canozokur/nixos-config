{ pkgs, ... }:
{
  home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
    pkgs.hack-font
    pkgs.font-awesome
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = ["caskaydia-cove"];
  };
}
