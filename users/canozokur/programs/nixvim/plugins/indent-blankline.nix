{ ... }:
{
  plugins = {
    indent-blankline = {
      enable = true;
      settings.whitespace.remove_blankline_trail = false;
      lazyLoad = {
        enable = true;
        settings = {
          event = ["BufNew"];
        };
      };
    };
  };

  opts = {
    list = true;
    listchars = {
        multispace = "·";
        eol        = "↲";
        tab        = "│ ";
        trail      = "·";
    };
  };
}
