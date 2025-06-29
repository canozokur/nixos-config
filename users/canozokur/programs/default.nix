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
    ./swaylock.nix
    ./cliphist.nix
    ./wlsunset.nix
    ./i3status-rs.nix
    ./ssh-agent.nix
    ./keybase.nix
    ./ssh.nix
    ./direnv.nix
    ./google-cloud-sdk.nix
    ./flameshot.nix
    ./kanshi.nix
    ./nix.nix
    ./swaync.nix
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
    spotify
  ];
}
