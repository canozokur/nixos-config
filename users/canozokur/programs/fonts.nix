{ pkgs, ... }:
{
  home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = ["caskaydia-cove"];
  };
}
