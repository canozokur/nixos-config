{ nixpkgs, inputs }:
{ box, system }:
{
  nixosConfigurations.${box} = nixpkgs.lib.nixosSystem {
    inherit system inputs;
    modules = [
      ../boxes/${box}/hardware-configuration.nix
      ../boxes/${box}/configuration.nix
      ];
  };
}
