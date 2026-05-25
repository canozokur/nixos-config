{ inputs, config, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    imports = [
      ./nixvim.nix
      ./common-options.nix
    ];

    _module.args.hmConfig = config;
  };
}
