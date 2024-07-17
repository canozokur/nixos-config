{ nixpkgs }:
{ box, system }:
{
  ${box} = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ../boxes/${box}/hardware-configuration.nix
      ../boxes/${box}/configuration.nix
    ];
  };
}
