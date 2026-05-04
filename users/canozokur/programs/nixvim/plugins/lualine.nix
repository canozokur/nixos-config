{ lib, config, ... }:
{
  plugins = {
    lualine = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings = {
          event = [ "VimEnter" ];
        };
      };
      settings = {
        options = {
          disabled_filetypes = {
            statusline = lib.optionals (config.plugins.dap-view.enable or false) [
              "dap-repl"
              "dap-view"
              "dap-view-watches"
              "dap-view-breakpoints"
              "dap-view-term"
            ];
          };
          component_separators = {
            left = "\\";
            right = "/";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_c = [
            {
              __unkeyed = "filename";
              file_status = true;
              newfile_status = true;
              path = 4;
            }
          ];
        };
      };
    };
  };
}
