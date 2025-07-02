{ ... }:
{
  imports = [
    ./options.nix
    ./keymap.nix
    ./filetype.nix
    ./colorscheme.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    enableMan = false;
    defaultEditor = true;
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
