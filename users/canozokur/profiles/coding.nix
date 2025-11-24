{ pkgs, ... }:
{
  imports = [
    ../programs/direnv.nix
    ../programs/google-cloud-sdk.nix
    ../programs/aider.nix
    ../programs/qemu.nix
  ];

  home.packages = with pkgs; [
    kubectl
    kubectx
    devenv
  ];
}
