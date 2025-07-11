{ pkgs, ... }:
{
  imports = [
    ./shell-config.nix
    ./git.nix
    ./sway.nix
    ./ghostty.nix
    ./fonts.nix
    ./firefox.nix
    ./zellij.nix
    ./rofi.nix
    ./cliphist.nix
    ./wlsunset.nix
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
#    ./hyprland.nix
    ./waybar
    ./mouse-cursor.nix
    ./clipboard.nix
    ./wpaperd.nix
    ./playerctld.nix
    ./hyprlock.nix
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
