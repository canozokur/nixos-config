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
}
