{
  inputs,
  home-manager,
  helpers,
  constants,
}:
{
  box,
  system,
  users,
  profiles,
  userProfiles ? [ ],
}:
let
  lib = inputs.nixpkgs.lib;

  resolveProfile =
    pathPrefix: profile:
    let
      profilePath = pathPrefix + "/${profile}.nix";
    in
    if builtins.pathExists profilePath then
      profilePath
    else
      throw "mkBox: profile not found at ${toString profilePath}";

  mkUser = user: [
    ../users/${user}/default.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          system
          constants
          ;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        imports = [
          ../users/${user}/profiles/common.nix
        ]
        ++ map (resolveProfile ../users/${user}/profiles) userProfiles;
      };
    }
  ];
in
lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs helpers constants;
  };

  modules = [
    ../boxes/${box}
    # import common profile
    ../profiles/core/common.nix
  ]
  ++ builtins.concatLists (map mkUser users)
  ++ map (resolveProfile ../profiles) profiles;
}
