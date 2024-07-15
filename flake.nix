{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }@inputs: 
  let
    mkBox = import ./lib/mkbox.nix {
      inherit nixpkgs inputs;
    };
  in
  {
    mkBox {
      box = "virtnixbox";
      system = "x86_64-linux";
    };
   # nixosConfigurations.virtnixbox = nixpkgs.lib.nixosSystem {
   #   system = "x86_64-linux";
   #   modules = [
   #     ./virtnixbox/hardware-configuration.nix
   #     ./configuration.nix
   #   ];
   # };
  };
}
