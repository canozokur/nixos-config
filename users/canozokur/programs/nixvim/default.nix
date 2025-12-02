{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    imports = [
      ./nixvim.nix
    ];

    defaultEditor = true;
    enable = true;
    enableMan = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPerl = false;
    withPython3 = false;
    withRuby = false;
    # EXPERIMENTAL! luaLoader and combinePlugins are experimental
    luaLoader.enable = true;
    performance.combinePlugins.enable = true;
    plugins.lz-n.enable = true; # enable lazy loading
    dependencies.gcc.enable = true;
  };
}
