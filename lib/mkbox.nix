{ inputs, home-manager }:
{ box, system, users, profiles }:
let
  lib = inputs.nixpkgs.lib;

  mkUser = user: [
    # inline module to merge the host overrides for home-manager configuration
    ../users/${user}/default.nix
    ({ config, inputs, ... }: {
      imports = [ home-manager.nixosModules.home-manager ];
      home-manager.extraSpecialArgs = {
        inherit inputs;
        inherit system;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
      home-manager.users.${user} = {
        imports = [
          ../users/${user}/profiles/common.nix
        ] ++ builtins.map (mkProfile ../users/${user}/profiles) profiles;
        config = config.hostOverridesForPrograms or {};
      };
    })
  ];

  mkProfile = pathPrefix: profile: 
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
  };

  modules = [
    # Define _meta options
    ({ lib, ... }: {
      options._meta = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Metadata about the configuration";
      };
    })

    # another inline module so we can define a "hostSpecificOverrides" config option and use it later
    ({ lib, ... }: {
      options.hostSpecificOverrides = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Host-specific overrides to be merged into the main home-manager config.";
      };
    })
    ../boxes/${box}
    # import common profile
    ../profiles/common.nix
  ] ++ builtins.concatLists (builtins.map mkUser users)
    ++ builtins.map (mkProfile ../profiles) profiles;
}
