{ inputs, ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./configuration-overrides
    ./overlays
    ../_shared/bazecor.nix
    ./steam.nix
  ];
}
