{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = [pkgs.vimPlugins.lzn-auto-require];
  programs.nixvim.extraConfigLuaPost = ''
    require('lzn-auto-require').enable()
  '';
}
