{ pkgs, ... }:
{
  imports = [
    ../programs/nixvim
  ];

  home.packages = with pkgs; [
    direnv
  ];
}
