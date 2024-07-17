{ nixpkgs }:
{ boxes }:
let
  mkSingleBox = box: system:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ../boxes/${box}/hardware-configuration.nix
        ../boxes/${box}/configuration.nix
      ];
    };
in
builtins.mapAttrs (name: value: mkSingleBox name value.system) boxes
