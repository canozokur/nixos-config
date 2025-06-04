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
    plugins.lz-n.enable = true; # enable lazy loading
  };
}
