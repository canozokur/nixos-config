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

    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    mkBox = import ./lib/mkbox.nix {
      inherit inputs;
      inherit nixpkgs;
      inherit home-manager;
    };

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in
  {
    nixosConfigurations.virtnixbox = mkBox {
      box = "virtnixbox";
      system = "x86_64-linux";
      users = [ "canozokur" ];
    };

    nixosConfigurations.nexusbox = mkBox {
      box = "nexusbox";
      system = "x86_64-linux";
      users = [ "canozokur" ];
    };

    devShells = forAllSystems (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            sops
            age
            ssh-to-age
            just
          ];
        };
      }
    );
  };
}
