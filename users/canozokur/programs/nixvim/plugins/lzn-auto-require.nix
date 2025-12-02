{ pkgs, ... }:
{
  extraPlugins = [pkgs.vimPlugins.lzn-auto-require];
  extraConfigLuaPost = ''
    require('lzn-auto-require').enable()
  '';
}
