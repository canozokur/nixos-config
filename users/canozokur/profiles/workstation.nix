{ pkgs, ... }:
{
  imports = [
    ./capabilities/desktop.nix
    ./capabilities/coding.nix
    ../programs/vault.nix
  ];

  home.packages = with pkgs; [
    slack
  ];
}
