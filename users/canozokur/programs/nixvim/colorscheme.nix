{ ... }:
{
  colorschemes = {
    catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
        dim_inactive.enabled = false;
        integrations = {
          native_lsp = {
            enabled = true;
            underlines = {
              errors = ["undercurl"];
              hints = ["undercurl"];
              warnings = ["undercurl"];
              information = ["undercurl"];
            };
          };
        };
      };
    };
  };
}
