{ pkgs, ... }:
{
  extraPlugins = [
    pkgs.vimPlugins.lazy-lsp-nvim
  ];

  extraConfigLua = ''
    local lsp_zero = require("lsp-zero")

    lsp_zero.on_attach(function(client, bufnr)
      -- see :help lsp-zero-keybindings to learn the available actions
      lsp_zero.default_keymaps({
        buffer = bufnr,
        preserve_mappings = false
      })
    end)

    require("lazy-lsp").setup {
      --see https://github.com/dundalek/lazy-lsp.nvim/issues/63
      use_vim_lsp_config = true,
      excluded_servers = {
        "ccls",                            -- prefer clangd
        "denols",                          -- prefer eslint and tsserver
        "docker_compose_language_service", -- yamlls should be enough?
        "flow",                            -- prefer eslint and tsserver
        "ltex",                            -- grammar tool using too much CPU
        "quick_lint_js",                   -- prefer eslint and tsserver
        "rnix",                            -- archived on Jan 25, 2024
        "scry",                            -- archived on Jun 1, 2023
        "tailwindcss",                     -- associates with too many filetypes
      },
      preferred_servers = {
        nix = { "nixd" },
        helm = { "helm_ls" },
        python = { "jedi_language_server", "ruff", "pyright" },
      },
      configs = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
      },
    }
  '';
}
