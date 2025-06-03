{ ... }:
{
  programs.nixvim.plugins = {
    harpoon = {
      enable = true;
      enableTelescope = true;
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<C-e>";
      action.__raw = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end";
      mode = "n";
      options.desc = "Open Harpoon quick menu";
    }
    {
      key = "<leader>a";
      action.__raw = "function() require'harpoon':list():add() end";
      mode = "n";
      options.desc = "Add file to harpoon";
    }
    {
      key = "<S-C-e>";
      action.__raw = "function() require'harpoon':list():clear() end";
      mode = "n";
      options.desc = "Clear Harpoon file list";
    }
  ];
}

