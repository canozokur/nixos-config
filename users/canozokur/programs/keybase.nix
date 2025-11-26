{ pkgs, lib, system, ... }:
{
  services.keybase.enable = true;
  services.kbfs.enable = true;
  # keybase-gui only avaiable in x86_64-linux
  home.packages = lib.optionals (system == "x86_64-linux") [
    pkgs.keybase-gui
  ];
}
