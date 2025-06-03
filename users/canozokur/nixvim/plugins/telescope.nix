{ ... }:
{
  programs.nixvim.plugins = {
    telescope = {
      enable = true;
      settings = {
        defaults = {
          mappings = {
            i = {
              "<C-q>" = {
                __raw = "require'telescope.actions'.smart_add_to_qflist + require'telescope.actions'.open_qflist";
              };
              "<C-e>" = {
                __raw = "require'telescope'.extensions.send_to_harpoon.actions.send_selected_to_harpoon";
              };
            };
          };
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<C-o>";
      action.__raw = "function() require'telescope.builtin'.find_files({ hidden = true, file_ignore_patterns = { 'node_modules', '.git/', '.venv' }}) end";
      mode = "n";
    }
  ];
}
