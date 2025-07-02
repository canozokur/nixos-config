{ ... }:
{
  programs.nixvim.colorschemes = {
    catppuccin = {
      enable = true;
      lazyLoad.enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
        dim_inactive.enabled = false;
      };
    };
  };
}
