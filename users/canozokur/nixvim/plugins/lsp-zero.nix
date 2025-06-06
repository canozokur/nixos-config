{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = [
    pkgs.vimPlugins.lsp-zero-nvim
  ];

  programs.nixvim.extraConfigLua = ''
    local lsp_zero = require('lsp-zero')

    lsp_zero.on_attach(function(client, bufnr)
      local opts = { buffer = bufnr, remap = false }

      vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set("n", "gr", '<cmd>Telescope lsp_references<cr>', opts)
      vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>', opts)
      vim.keymap.set("n", "<leader>gn", function() vim.diagnostic.goto_next() end, opts)
      vim.keymap.set({ 'n', 'x' }, '=', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
      vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
      vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
      vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
      vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
      vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
      vim.keymap.set("n", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
      -- see :help lsp-zero-keybindings
      -- to learn the available actions
      lsp_zero.default_keymaps({ buffer = bufnr })
    end)
  '';

  programs.nixvim.plugins = {
    lsp.enable = true; # lsp-zero requires these two
    luasnip.enable = true;
  };

}
