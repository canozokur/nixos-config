{ nixpkgs, home-manager }:
{ box, system, users }:
let
  mkUser = user: [
    ../users/${user}/nixos.nix
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import ../users/${user}/home-manager.nix;
    }
  ];
in
{
  ${box} = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ../boxes/${box}/hardware-configuration.nix
      ../boxes/${box}/configuration.nix
    ] ++ builtins.concatLists (builtins.map mkUser users);
  };
}
