{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: 
  let
    mkBox = import ./lib/mkbox.nix {
      inherit nixpkgs;
      inherit home-manager;
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
