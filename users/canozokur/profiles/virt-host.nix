{ pkgs, ... }:
{
  home.packages = with pkgs; [
    looking-glass-client
  ];
}
