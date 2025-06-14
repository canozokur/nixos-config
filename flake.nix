{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/canozokur/nix-secrets.git?ref=main&shallow=1";
      inputs = {};
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    mkBox = import ./lib/mkbox.nix {
      inherit inputs;
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
