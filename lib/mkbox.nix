{
  inputs,
  home-manager,
  helpers,
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
        inherit inputs system;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        imports = [
          ../users/${user}/profiles/common.nix
        ]
        ++ builtins.map (mkProfile ../users/${user}/profiles) profiles;
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
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs;
    inherit helpers;
  };

  modules = [
    ../boxes/${box}
    # import common profile
    ../profiles/core/common.nix
  ]
  ++ builtins.concatLists (builtins.map mkUser users)
  ++ builtins.map (mkProfile ../profiles) profiles;
}
