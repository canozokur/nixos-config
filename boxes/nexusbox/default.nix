{ ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./configuration-overrides
    ./overlays
  ];
}
