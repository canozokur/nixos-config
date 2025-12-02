{ ... }:
{
  plugins = {
    barbar = {
      enable = true;
      keymaps = {
        pick.key = "<C-p>";
        pickDelete.key = "<C-s-p>";
        close.key = "<A-c>";
      };
      lazyLoad = {
        enable = true;
        settings = {
          event = ["BufRead"];
        };
      };
    };

    # barbar depends on web-devicons and gitsigns
    web-devicons.enable = true;
    gitsigns.enable = true;
  };
}
