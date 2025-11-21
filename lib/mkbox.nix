{ inputs, home-manager }:
{ box, system, users, profiles }:
let
  lib = inputs.nixpkgs.lib;

  mkUser = user: [
    ../users/${user}/nixos.nix
    # inline module to merge the host overrides for home-manager configuration
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
          ../users/${user}/home-manager.nix
        ];
        config = config.hostOverridesForPrograms or {};
      };
    })
  ];

  mkProfile = profile: 
  let
    profilePath = ../profiles/${profile}.nix;
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
    # another inline module so we can define a "hostSpecificOverrides" config option and use it later
    ({ lib, ... }: {
      options.hostSpecificOverrides = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Host-specific overrides to be merged into the main home-manager config.";
      };
    })
    ../boxes/_shared
    ../boxes/${box}
  ] ++ builtins.concatLists (builtins.map mkUser users)
    ++ builtins.map mkProfile profiles;
}
