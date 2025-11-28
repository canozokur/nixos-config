{ pkgs, ... }:
{
  imports = [
    ../programs/shell-config.nix
    ../programs/zellij.nix
    ../programs/ghostty.nix
    ../programs/fonts.nix
    ../programs/firefox.nix
    ../programs/rofi.nix
    ../programs/cliphist.nix
    ../programs/wlsunset.nix
    ../programs/keybase.nix
    ../programs/kanshi.nix
    ../programs/wezterm.nix
    ../programs/swaync.nix
    ../programs/hyprland.nix
    ../programs/waybar
    ../programs/mouse-cursor.nix
    ../programs/clipboard.nix
    ../programs/wpaperd.nix
    ../programs/playerctld.nix
    ../programs/hyprlock.nix
    ../programs/xdg-portal.nix
    ../programs/udiskie.nix
  ];
  home.packages = with pkgs; [
    obsidian
    # slurp, grim and satty are required for screenshots
    slurp
    grim
    satty
    obs-studio
    cameractrls-gtk4
  ] ++ lib.optionals (system != "aarch64-linux") [
    spotify
  ];

  # enable bluetooth by default
  services.blueman-applet.enable = true;
}
