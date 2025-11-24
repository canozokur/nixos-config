{ pkgs, ... }:
{
  imports = [
    ./direnv.nix
    ./google-cloud-sdk.nix
    ./aider.nix
    ./vault.nix
    ./qemu.nix
  ];

  home.packages = with pkgs; [
    kubectl
    kubectx
    (zoom-us.override { hyprlandXdgDesktopPortalSupport = true; })
    slack
    devenv
  ];
}
