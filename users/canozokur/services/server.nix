{ pkgs, ... }:
{
  imports = [
    ../programs/nixvim
    ../programs/direnv.nix
  ];
}
