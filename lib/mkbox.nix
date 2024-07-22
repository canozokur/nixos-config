{ nixpkgs, inputs }:
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
      inputs.hm.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.canozokur = import ../users/canozokur/home.nix;
      }
    ] ++ builtins.concatLists (builtins.map mkUser users);
  };
}
