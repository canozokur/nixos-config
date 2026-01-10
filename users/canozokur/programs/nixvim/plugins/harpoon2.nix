{ ... }:
{
  plugins = {
    harpoon = {
      enable = true;
      enableTelescope = true;
    };
  };

  plugins.lz-n.keymaps = [
    {
      key = "<C-e>";
      action.__raw = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end";
      mode = "n";
      options.desc = "Open Harpoon quick menu";
      plugin = "harpoon";
    }
    {
      key = "<leader>a";
      action.__raw = "function() require'harpoon':list():add() end";
      mode = "n";
      options.desc = "Add file to harpoon";
      plugin = "harpoon";
    }
    {
      key = "<S-C-e>";
      action.__raw = "function() require'harpoon':list():clear() end";
      mode = "n";
      options.desc = "Clear Harpoon file list";
      plugin = "harpoon";
    }
  ];
}
