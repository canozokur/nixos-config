{ ... }:
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        auto_install = true;
        ensure_installed = [
          "go"
          "python"
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
