{ pkgs, nixvim, sops-nix, ... }:
{
  imports = [
    nixvim.homeManagerModules.nixvim
    sops-nix.homeManagerModules.sops
    ./nixvim
    ./programs
    ./sops.nix
  ];

  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    fzf
    tree
    jq
    htop
    ripgrep
    watch
  ];
}
