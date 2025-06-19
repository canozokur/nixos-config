{ inputs, ... }:
{
  imports = [
    inputs.kolide-launcher.nixosModules.kolide-launcher
    ./configuration.nix
    ./hardware-configuration.nix
    ./configuration-overrides
    ./overlays
    ./kolide.nix
  ];
}
