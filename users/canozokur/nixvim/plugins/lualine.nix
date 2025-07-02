{ ... }:
{
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings = {
          event = ["VimEnter"];
        };
      };
    };
  };
}
