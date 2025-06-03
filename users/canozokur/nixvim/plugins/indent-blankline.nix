{ ... }:
{
  programs.nixvim.plugins = {
    indent-blankline = {
      enable = true;
      settings.whitespace.remove_blankline_trail = false;
    };
  };

  programs.nixvim.opts = {
    list = true;
    listchars = {
        multispace = "·";
        eol        = "↲";
        tab        = "→ ";
        trail      = "·";
    };
  };
}
