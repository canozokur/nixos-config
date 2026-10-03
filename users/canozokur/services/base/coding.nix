{ pkgs, ... }:
{
  imports = [
    ../../programs/direnv.nix
    ../../programs/google-cloud-sdk.nix
    ../../programs/qemu.nix
    ../../programs/nixvim
    ../../programs/claude-code.nix
  ];

  home.packages = with pkgs; [
    kubectl
    kubectx
    devenv
    plannotator
  ];
}
