{ ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      settings = {
        auto_install = false;
        highlight = { enable = true; };
      };
    };
  };
}
