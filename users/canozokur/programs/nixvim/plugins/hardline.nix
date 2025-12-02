{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "nvim-hardline";
      src = pkgs.fetchFromGitHub {
          owner = "ojroques";
          repo = "nvim-hardline";
          rev = "9b85ebfba065091715676fb440c16a37c465b9a5";
          hash = "sha256-BY5uo5Fo9bAg0cy1GZLMglcc4lVt22q15PKIRIJgqd8=";
      };
    })
  ];

  extraConfigLua = ''
    require('hardline').setup {
      bufferline = false,         -- disable bufferline
      bufferline_settings = {
        exclude_terminal = false, -- don't show terminal buffers in bufferline
        show_index = false,       -- show buffer indexes (not the actual buffer numbers) in bufferline
      },
      theme = 'default',          -- change theme
      sections = {                -- define sections
        { class = 'mode', item = require('hardline.parts.mode').get_item },
        { class = 'high', item = require('hardline.parts.git').get_item,     hide = 100 },
        { class = 'med',  item = require('hardline.parts.filename').get_item },
        '%<',
        { class = 'med',     item = '%=' },
        { class = 'low',     item = require('hardline.parts.wordcount').get_item, hide = 100 },
        { class = 'error',   item = require('hardline.parts.lsp').get_error },
        { class = 'warning', item = require('hardline.parts.lsp').get_warning },
        { class = 'warning', item = require('hardline.parts.whitespace').get_item },
        { class = 'high',    item = require('hardline.parts.filetype').get_item,  hide = 60 },
        { class = 'mode',    item = require('hardline.parts.line').get_item },
      },
    }
  '';
}
