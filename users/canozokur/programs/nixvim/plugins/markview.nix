{ pkgs, ... }:
{
  plugins = {
    markview = {
      enable = true;
      lazyLoad.enable = false;
      settings = {
        preview = {
          enable = true;
          filetypes = [
            "markdown"
            "codecompanion"
          ];
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

  autoCmd = [
    {
      event = "FileType";
      pattern = "codecompanion";
      callback = {
        __raw = ''
          function(args)
            local ok, actions = pcall(require, "markview.actions")
            if ok then
              actions.attach(args.buf)
            end
          end
        '';
      };
    }
  ];

  # see:
  # https://github.com/nix-community/nixvim/issues/3843#issuecomment-3435139071
  performance.combinePlugins.standalonePlugins = [
    pkgs.vimPlugins.markview-nvim
  ];
}
