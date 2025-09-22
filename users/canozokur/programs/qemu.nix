{ pkgs, ... }:
{
  home.packages = [
    pkgs.qemu
    pkgs.quickemu
  ];
}
