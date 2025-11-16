{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    hyprcursor = {
      enable = true;
      size = 24;
    };
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
  };
}
