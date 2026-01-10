{ pkgs, ... }:
{
  extraPlugins = [
    {
      plugin = pkgs.vimPlugins.vim-suda;
      optional = true;
    }
  ];

  plugins = {
    lz-n = {
      plugins = [
        {
          __unkeyed-1 = "vim-suda";
          event = [ "BufRead" ];
        }
      ];
    };
  };

}
