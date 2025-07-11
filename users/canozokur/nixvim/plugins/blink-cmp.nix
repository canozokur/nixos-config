{ ... }:
{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap = { preset = "default"; };
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
