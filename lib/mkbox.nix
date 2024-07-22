{ nixpkgs, inputs }:
{ box, system, users }:
let
  hm = inputs.hm.nixosModules.home-manager;
  mkUser = user: [
    ../users/${user}/nixos.nix
    ../users/${user}/home-manager.nix
    hm {
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
