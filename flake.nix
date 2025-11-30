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
      url = "git+ssh://git@github.com/canozokur/nix-secrets.git?ref=main&shallow=1&lfs=1";
      inputs = {};
    };

    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    zjstatus = {
      url = "github:dj95/zjstatus";
    };

    wallpapers = {
      url = "github:canozokur/wallpapers";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, self, ... }:
  let
    mkBox = import ./lib/mkbox.nix {
      inherit inputs;
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
      profiles = [ "virtual" "desktop" "coding" "gaming" ];
    };

    nixosConfigurations.nexusbox = mkBox {
      box = "nexusbox";
      system = "x86_64-linux";
      users = [ "canozokur" ];
      profiles = [ "laptop" "desktop" "coding" "work" ];
    };

    nixosConfigurations.homebox = mkBox {
      box = "homebox";
      system = "x86_64-linux";
      users = [ "canozokur" ];
      profiles = [
        "desktop"
        "coding"
        "gaming"
        "remote-builder"
      ];
    };

    nixosConfigurations.rpi01 = mkBox {
      box = "rpi01";
      system = "aarch64-linux";
      users = [ "canozokur" ];
      profiles = [
        "server"
        "pihole"
        "remote-builder-client"
        "pi-image"
      ];
    };

    nixosConfigurations.rpi02 = mkBox {
      box = "rpi02";
      system = "aarch64-linux";
      users = [ "canozokur" ];
      profiles = [
        "server"
        "remote-builder-client"
        "pi-image"
      ];
    };

    nixosConfigurations.rpi03 = mkBox {
      box = "rpi03";
      system = "aarch64-linux";
      users = [ "canozokur" ];
      profiles = [
        "server"
        "remote-builder-client"
        "pi-image"
      ];
    };

    images = {
      rpi01 = self.nixosConfigurations.rpi01.config.system.build.sdImage;
      rpi02 = self.nixosConfigurations.rpi02.config.system.build.sdImage;
      rpi03 = self.nixosConfigurations.rpi03.config.system.build.sdImage;
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
