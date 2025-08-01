{ inputs, ... }:
{
  imports = [
    inputs.kolide-launcher.nixosModules.kolide-launcher
    inputs.nixos-hardware.nixosModules.dell-xps-15-9510
    ./configuration.nix
    ./hardware-configuration.nix
    ./configuration-overrides
    ./overlays
    ./kolide.nix
    ./falcon-sensor.nix
    ./undervolt.nix
    ./netbird.nix
    ../_shared/bazecor.nix
  ];
}
