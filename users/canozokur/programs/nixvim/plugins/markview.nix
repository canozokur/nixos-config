{ pkgs, ... }:
{
  plugins = {
    markview = {
      enable = true;
      settings = {
        preview = {
          enable = false;
          enable_hybrid_mode = false;
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
