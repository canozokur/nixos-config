{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    hack-font
    font-awesome
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "caskaydia-cove" ];
  };
}
