{ ... }:
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
  ];
}
