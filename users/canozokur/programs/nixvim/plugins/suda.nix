{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = [
    {
      plugin = pkgs.vimPlugins.vim-suda;
      optional = true;
    }
  ];

  programs.nixvim.plugins = {
    lz-n = {
      plugins = [
        {
          __unkeyed-1 = "vim-suda";
          event = ["BufRead"];
        }
      ];
    };
  };

}
