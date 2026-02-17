{ ... }:
{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<Tab>" = [
            { __raw = "function(cmp) if cmp.snippet_active() then return cmp.accept() else return cmp.select_and_accept() end end"; }
            "snippet_forward"
            "fallback"
          ];
        };
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
      };
    };
  };
}
