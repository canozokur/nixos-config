{ ... }:
{
  programs.nixvim.colorschemes = {
    tokyonight = {
      enable = true;
      settings = {
        style = "moon";
        transparent = true;
        dim_inactive = false;
        on_colors = "function(colors) colors.bg = colors.bg_dark1 end";
      };
    };
  };
}
