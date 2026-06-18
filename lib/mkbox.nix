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
  services,
  userServices ? [ ],
}:
let
  lib = inputs.nixpkgs.lib;

  optionalPath =
    path:
    if builtins.pathExists (toString path) then [ path ] else [ ];

  resolveService =
    name:
    let
      servicePath = ../services + "/${name}.nix";
    in
    if builtins.pathExists servicePath then
      [ servicePath ] ++ optionalPath ../boxes/${box}/${name}/default.nix
    else
      throw "mkBox: service not found at ${toString servicePath}";

  resolveUserService =
    user: name:
    let
      servicePath = ../users/${user}/services + "/${name}.nix";
    in
    optionalPath servicePath;

  mkUser =
    user:
    [
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
            ../users/${user}/services/common.nix
          ]
          ++ builtins.concatMap (resolveUserService user) userServices;
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
    ../services/core/common.nix
  ]
  ++ builtins.concatLists (map mkUser users)
  ++ builtins.concatMap resolveService services;
}
