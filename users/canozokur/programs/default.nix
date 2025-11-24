{ pkgs, ... }:
{
  imports = [
    ./shell-config.nix
    ./git.nix
    ./zellij.nix
    ./ssh-agent.nix
    ./ssh.nix
    ./direnv.nix
    ./google-cloud-sdk.nix
    ./nix.nix
    ./aider.nix
    ./lazygit.nix
    ./vault.nix
    ./qemu.nix
    ./yazi.nix
  ];

  home.packages = with pkgs; [
    fzf
    tree
    jq
    htop
    ripgrep
    watch
    kubectl
    kubectx
    (zoom-us.override { hyprlandXdgDesktopPortalSupport = true; })
    slack
    devenv
  ];
}
