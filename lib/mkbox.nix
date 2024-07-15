{ nixpkgs }:
{ box, system }:
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../boxes/${box}/hardware-configuration.nix
    ../boxes/${box}/configuration.nix
  ];
}
