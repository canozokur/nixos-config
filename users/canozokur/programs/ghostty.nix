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
      theme = "Catppuccin Mocha";
      window-decoration = "server";
      alpha-blending = "native";
      minimum-contrast = 1.1;
      background-opacity = 0.97;
      bold-is-bright = true;
      confirm-close-surface = false;
      resize-overlay = "never";
      keybind = [
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
        "ctrl+plus=increase_font_size:1"
      ];
    };
  };
}
