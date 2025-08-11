{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.sops-nix.homeManagerModules.sops
    ./nixvim
    ./programs
    ./sops.nix
  ];

  # allow unfree in our shell
  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

  home.stateVersion = "24.05";
}
