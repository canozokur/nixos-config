{ ... }:
{
  programs.nixvim.plugins = {
    barbar = {
      enable = true;
      keymaps = {
        pick.key = "<C-p>";
        pickDelete.key = "<C-s-p>";
      };
    };

    # barbar depends on web-devicons and gitsigns
    web-devicons.enable = true;
    gitsigns.enable = true;
  };
}
