{ ... }:
{
  plugins.luasnip.enable = true;

  plugins.lsp = {
    enable = true;
    servers = {
      pyright.enable = true;
      ruff.enable = true;
      nixd.enable = true;
      helm_ls.enable = true;
      clangd.enable = true;
      eslint.enable = true;
      ts_ls.enable = true;
      yamlls.enable = true;
      gopls.enable = true;
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            diagnostics = {
              globals = [ "vim" ];
            };
          };
        };
      };
    };

    keymaps = {
      diagnostic = {
        "<leader>gn" = "goto_next";
        "<leader>vd" = "open_float";
        "<leader>fe" = "setqflist";
      };

      lspBuf = {
        "gd" = "definition";
        "K" = "hover";
        "<leader>ws" = "workspace_symbol";
        "<leader>ca" = "code_action";
        "<leader>rr" = "references";
        "<leader>rn" = "rename";
        "<C-h>" = "signature_help";
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "gr";
      action = "<cmd>Telescope lsp_references<cr>";
      options.desc = "Telescope LSP References";
    }
    {
      mode = "n";
      key = "gi";
      action = "<cmd>Telescope lsp_implementations<cr>";
      options.desc = "Telescope LSP Implementations";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "==";
      action = "<cmd>lua vim.lsp.buf.format({async = true})<cr>";
      options.desc = "Format buffer (LSP)";
    }
  ];
}
