{ pkgs, ... }:
{
  imports = [
    ../programs/vault.nix
  ];

  home.packages = with pkgs; [
    slack
  ];
}
