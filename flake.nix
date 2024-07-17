{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }@inputs: 
  let
    mkBox = import ./lib/mkbox.nix {
      inherit nixpkgs;
    };
  in
  {
    nixosConfigurations = mkBox {
      virtnixbox = {
        system = "x86_64-linux";
      };
    };
  };
}
