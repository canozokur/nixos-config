{ ... }:
{
  programs.ghostty = {
    enable = true;
    clearDefaultKeybinds = true;
    settings = {
      font-family = "CaskaydiaCove Nerd Font Mono";
      font-size = 12;
      window-padding-x = 0;
      window-padding-y = 0;
      theme = "catppuccin-mocha";
      window-decoration = "server";
      alpha-blending = "native";
      minimum-contrast = 1.1;
      background-opacity = 0.97;
      bold-is-bright = true;
      confirm-close-surface = false;
      gtk-adwaita = false;
      resize-overlay = "never";
    };
  };
}
