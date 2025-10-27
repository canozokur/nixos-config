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
    ./netbird.nix
    ./power.nix
    ./gpclient.nix
    ../_shared/bazecor.nix
  ];
}
