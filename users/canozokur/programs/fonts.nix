{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    hack-font
    font-awesome
  ];

  fonts.fontconfig = {
    enable = true;
    # hopefuly better fonts
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";

    defaultFonts.monospace = [ "caskaydia-cove" ];
  };
}
