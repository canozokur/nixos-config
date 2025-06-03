{ ... }:
{
  programs.nixvim.plugins = {
    indent-blankline = {
      enable = true;
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
