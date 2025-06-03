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

  # needs to happen before all config to make this function available to
  # leader keymaps
  programs.nixvim.extraConfigLuaPre = ''
    local function live_grep_from_project_git_root()
      local function is_git_repo()
        vim.fn.system("git rev-parse --is-inside-work-tree")

        return vim.v.shell_error == 0
      end

      local function get_git_root()
        local dot_git_path = vim.fn.finddir(".git", ".;")
        return vim.fn.fnamemodify(dot_git_path, ":h")
      end

      local opts = {}

      if is_git_repo() then
        opts = {
          cwd = get_git_root(),
        }
      end

      require("telescope.builtin").live_grep(opts)
    end
  '';

  programs.nixvim.keymaps = [
    {
      key = "<C-o>";
      action.__raw = "function() require'telescope.builtin'.find_files({ hidden = true, file_ignore_patterns = { 'node_modules', '.git/', '.venv' }}) end";
      mode = "n";
    }
    {
      key = "<leader>ps";
      action.__raw = "function() live_grep_from_project_git_root() end";
      mode = "n";
    }
    {
      key = "<leader>ff";
      action.__raw = "function() require'telescope.builtin'.lsp_document_symbols({ symbols = 'function' }) end";
      mode = "n";
    }
    {
      key = "<leader>fa";
      action.__raw = "function() require'telescope.builtin'.lsp_document_symbols() end";
      mode = "n";
    }
  ];
}
