{ inputs, nixpkgs, home-manager }:
{ box, system, users }:
let
  mkUser = user: [
    ../users/${user}/nixos.nix
    # inline module to merge the host overrides for home-manager configuration
    ({ config, inputs, ... }: {
      imports = [ home-manager.nixosModules.home-manager ];
      home-manager.extraSpecialArgs = {
        inherit (inputs) nixvim;
        inherit (inputs) sops-nix;
        inherit (inputs) nix-secrets;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} =
        let
          userHomeFile = ../users/${user}/home-manager.nix;
          hostOverridesForPrograms = config.hostSpecificOverrides or {};
        in
        {
          imports = [ userHomeFile ];
          config = hostOverridesForPrograms;
        };
    })
  ];
in
nixpkgs.lib.nixosSystem {
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
  ] ++ builtins.concatLists (builtins.map mkUser users);
}
