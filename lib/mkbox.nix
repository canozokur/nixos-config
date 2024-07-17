{ nixpkgs }:
{ box, system, users }:
let
  mkUser = user: [
    ../users/${user}/nixos.nix
    ../users/${user}/home-manager.nix
  ];
in
{
  ${box} = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ../boxes/${box}/hardware-configuration.nix
      ../boxes/${box}/configuration.nix
      builtins.map mkUser users
    ];
  };
}
