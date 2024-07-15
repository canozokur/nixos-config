{ nixpkgs, inputs }:
{ box, system }:
nixpkgs.lib.nixosSystem {
  inherit system inputs;
  modules = [
    ../boxes/${box}/hardware-configuration.nix
    ../boxes/${box}/configuration.nix
  ];
}
