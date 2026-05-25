{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    imports = [
      ./nixvim.nix
      ./common-options.nix
    ];
  };

  enable = true;
  vimdiffAlias = true;
  defaultEditor = true;
  # nixvim started using its own nixpkgs, we need to set its config here
  nixpkgs.config.allowUnfree = true;
}
