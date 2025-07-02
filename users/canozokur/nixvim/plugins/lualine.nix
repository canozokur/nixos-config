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
      settings.options = {
        component_separators = {
          left = "\\";
          right = "/";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };
    };
  };
}
