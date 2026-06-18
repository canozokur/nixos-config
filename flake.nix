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
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/canozokur/nix-secrets.git?ref=main&shallow=1&lfs=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpapers = {
      url = "github:canozokur/wallpapers";
      flake = false;
    };

    falcon-sensor = {
      url = "github:canozokur/falcon-sensor-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      self,
      ...
    }:
    let
      helpers = import ./lib/helpers.nix { inherit (nixpkgs) lib; };
      constants = import ./lib/constants.nix;
      mkBox = import ./lib/mkbox.nix {
        inherit
          inputs
          home-manager
          helpers
          constants
          ;
      };

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];

      boxes = {
        nexusbox = {
          system = "x86_64-linux";
          users = [ "canozokur" ];
          services = [
            "base/laptop"
            "workstation"
          ];
          userServices = [
            "base/laptop"
            "workstation"
          ];
        };

        homebox = {
          system = "x86_64-linux";
          users = [ "canozokur" ];
          services = [
            "gaming"
            "sunshine"
            "virt-host"
          ];
          userServices = [
            "gaming"
          ];
        };

        rpi01 = {
          system = "aarch64-linux";
          users = [ "canozokur" ];
          services = [
            "pi"
            "pihole"
            "server"
            "prowlarr"
            "radarr"
            "sonarr"
            "emby"
            "nzbget"
            "qbit"
            "bazarr"
          ];
          userServices = [ "server" ];
        };

        rpi02 = {
          system = "aarch64-linux";
          users = [ "canozokur" ];
          services = [
            "pi"
            "pihole"
            "server"
            "mysql-node"
          ];
          userServices = [ "server" ];
        };

        rpi03 = {
          system = "aarch64-linux";
          users = [ "canozokur" ];
          services = [
            "pi"
            "server"
            "reverse-proxy"
            "ombi"
            "syncthing"
          ];
          userServices = [ "server" ];
        };

        rpi04 = {
          system = "aarch64-linux";
          users = [ "canozokur" ];
          services = [
            "pi"
            "server"
            "monitoring"
          ];
          userServices = [ "server" ];
        };

        "tr.pco.pink" = {
          system = "x86_64-linux";
          users = [ "canozokur" ];
          services = [
            "server"
          ];
          userServices = [ "server" ];
        };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (name: cfg: mkBox (cfg // { box = name; })) boxes;

      images = nixpkgs.lib.pipe self.nixosConfigurations [
        # hosts that import the sd-image module expose `system.build.sdImage`
        (nixpkgs.lib.filterAttrs (name: host: host.config.system.build ? sdImage))
        (nixpkgs.lib.mapAttrs (name: host: host.config.system.build.sdImage))
      ];

      devShells = forAllSystems (
        system:
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
              nixfmt
              gh
            ];
          };
        }
      );

      packages = forAllSystems (system: {
        neovim =
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            nixvimLib = inputs.nixvim.legacyPackages.${system};
          in
          nixvimLib.makeNixvimWithModule {
            inherit pkgs;
            module = import ./users/canozokur/programs/nixvim/standalone.nix { inherit inputs; };
          };
      });
    };
}
