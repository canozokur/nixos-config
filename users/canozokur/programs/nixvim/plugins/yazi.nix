{ ... }:
{
  globals = {
    loaded_netrwPlugin = 1;
  };

  keymaps = [
    {
      key = "<leader>pv";
      action.__raw = "function() require('yazi').yazi() end";
      mode = "n";
    }
  ];

  plugins = {
    yazi = {
      enable = true;
      settings = {
        open_for_directories = true;
      };
    };
  };
}
