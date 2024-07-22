{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hm.url = "github:nix-community/home-manager";
    hm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... }@inputs: 
  let
    mkBox = import ./lib/mkbox.nix {
      inherit nixpkgs;
      inherit inputs;
    };

  in
  {
    nixosConfigurations = mkBox {
      box = "virtnixbox";
      system = "x86_64-linux";
      users = [ "canozokur" ];
    };
  };
}
