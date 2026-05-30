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
}:
let
  lib = inputs.nixpkgs.lib;

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
        ++ map (mkProfile ../users/${user}/profiles) profiles;
      };
    }
  ];

  mkProfile =
    pathPrefix: profile:
    let
      profilePath = pathPrefix + "/${profile}.nix";
      profileExists = builtins.pathExists profilePath;
    in
    {
      imports = lib.optionals profileExists [ profilePath ];
      config = {
        warnings = lib.mkIf (!profileExists) [
          "The specified profile does not exist: ${profile}"
        ];
      };
    };
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
  ++ map (mkProfile ../profiles) profiles;
}
