{ ... }:
{
  plugins.gitsigns.enable = true;

  keymaps = [
    {
      key = "<leader>hq";
      action.__raw = "function() require('gitsigns').setqflist('all') end";
      mode = "n";
      options.desc = "Git hunks of all changed files to quickfix";
    }
    {
      key = "]h";
      action.__raw = "function() require('gitsigns').nav_hunk('next') end";
      mode = "n";
      options.desc = "Next git hunk";
    }
    {
      key = "[h";
      action.__raw = "function() require('gitsigns').nav_hunk('prev') end";
      mode = "n";
      options.desc = "Previous git hunk";
    }
    {
      key = "<leader>hp";
      action.__raw = "function() require('gitsigns').preview_hunk_inline() end";
      mode = "n";
      options.desc = "Preview git hunk inline";
    }
    {
      key = "<leader>hb";
      action.__raw = "function() require('gitsigns').toggle_current_line_blame() end";
      mode = "n";
      options.desc = "Toggle git blame on current line";
    }
  ];
}
