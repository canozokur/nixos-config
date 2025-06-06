{ pkgs, nixvim, ... }:
{
  imports = [
    nixvim.homeManagerModules.nixvim
    ./nixvim
    ./programs
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
