{ ... }:
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        auto_install = true;
        ensure_installed = [
          "javascript"
          "typescript"
          "c"
          "lua"
          "vim"
          "vimdoc"
          "query"
        ];
        highlight = { enable = true; };
      };
    };
  };
}
