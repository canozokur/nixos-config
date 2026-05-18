{ pkgs, ... }:
{
  plugins = {
    markview = {
      enable = true;
      lazyLoad.enable = false;
      settings = {
        preview = {
          enable = true;
          filetypes = [ "markdown" "codecompanion" ];
          ignore_buftypes = { __empty = null; };
          enable_hybrid_mode = true;
        };
      };
    };
  };

  keymaps = [
    {
      key = "<leader>m";
      action = "<CMD>Markview<CR>";
      mode = "n";
    }
  ];

  # see:
  # https://github.com/nix-community/nixvim/issues/3843#issuecomment-3435139071
  performance.combinePlugins.standalonePlugins = [
    pkgs.vimPlugins.markview-nvim
  ];
}
