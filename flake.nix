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
    helpers = import ./lib/helpers.nix { inherit (nixpkgs) lib; };
    mkBox = import ./lib/mkbox.nix {
      inherit inputs;
      inherit home-manager;
      inherit helpers;
    };

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];

    boxes = {
      nexusbox = {
        system = "x86_64-linux";
        users = [ "canozokur" ];
        profiles = [ "capabilities/laptop" "workstation" ];
      };

      homebox = {
        system = "x86_64-linux";
        users = [ "canozokur" ];
        profiles = [ "gaming" ];
      };

      rpi01 = {
        system = "aarch64-linux";
        users = [ "canozokur" ];
        profiles = [ "pi" "pihole" "server" ];
      };

      rpi02 = {
        system = "aarch64-linux";
        users = [ "canozokur" ];
        profiles = [ "pi" "pihole" "server" ];
      };

      rpi03 = {
        system = "aarch64-linux";
        users = [ "canozokur" ];
        profiles = [ "pi" "server" ];
      };

      rpi04 = {
        system = "aarch64-linux";
        users = [ "canozokur" ];
        profiles = [ "pi" "server" "monitoring" ];
      };
    };
  in
  {
    nixosConfigurations = nixpkgs.lib.mapAttrs (name: cfg: mkBox (cfg // { box = name; })) boxes;

    images = nixpkgs.lib.pipe self.nixosConfigurations [
      # based on the metadata exported from rpi-image profile ...
      (nixpkgs.lib.filterAttrs (name: host: 
        host.config._meta.buildImage or false
      ))
      # ... generate the image config
      (nixpkgs.lib.mapAttrs (name: host: 
        host.config.system.build.sdImage
      ))
    ];

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
            dnsutils
          ];
        };
      }
    );

    packages = forAllSystems (system: {
      neovim =
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixvimLib = inputs.nixvim.legacyPackages.${system};
        in
        nixvimLib.makeNixvimWithModule {
          inherit pkgs;
          module = import ./users/canozokur/programs/nixvim/standalone.nix { inherit inputs; };
        };
    });
  };
}
