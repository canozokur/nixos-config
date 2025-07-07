{ pkgs, ... }:
{
  imports = [
    ./shell-config.nix
    ./git.nix
#    ./sway.nix
    ./ghostty.nix
    ./fonts.nix
    ./firefox.nix
    ./zellij.nix
    ./rofi.nix
#    ./swaylock.nix
    ./cliphist.nix
    ./wlsunset.nix
#    ./i3status-rs.nix
    ./ssh-agent.nix
    ./keybase.nix
    ./ssh.nix
    ./direnv.nix
    ./google-cloud-sdk.nix
    ./kanshi.nix
    ./nix.nix
    ./swaync.nix
    ./spotify-player.nix
    ./wezterm.nix
    ./hyprland.nix
    ./waybar.nix
    ./mouse-cursor.nix
    ./clipboard.nix
  ];

  home.packages = with pkgs; [
    fzf
    tree
    jq
    htop
    ripgrep
    watch
    globalprotect-openconnect
    kubectl
    kubectx
    zoom-us
    slack
    devenv
    obsidian
    # slurp, grim and satty are required for screenshots
    slurp
    grim
    satty
  ];
}
