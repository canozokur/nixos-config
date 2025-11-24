{ ... }:
{
  programs.nixvim.plugins = {
    undotree = {
      enable = true;
      settings = {
        window = {
          winblend = 0;
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<leader>u";
      action = "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>";
      mode = "n";
    }
  ];
}
