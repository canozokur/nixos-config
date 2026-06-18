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
      gluePath = ../boxes/${box}/${name}/default.nix;
    in
    if builtins.pathExists servicePath || builtins.pathExists gluePath then
      optionalPath servicePath ++ optionalPath gluePath
    else
      throw "mkBox: service not found at ${toString servicePath} or ${toString gluePath}";

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
    mkReverseProxyService = import ./mkReverseProxyService.nix {
      inherit inputs helpers;
    };
  };

  modules = [
    ../boxes/${box}
    ../services/core/common.nix
  ]
  ++ builtins.concatLists (map mkUser users)
  ++ builtins.concatMap resolveService services;
}
