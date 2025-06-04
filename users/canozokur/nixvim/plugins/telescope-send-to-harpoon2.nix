{ pkgs, ... }:
let
  telescope-send-to-harpoon2 = pkgs.vimUtils.buildVimPlugin {
    name = "telescope-send-to-harpoon2";
    src = pkgs.fetchFromGitHub {
      owner = "TheNemoNemesis";
      repo = "telescope-send-to-harpoon2.nvim";
      rev = "eb457d3485056b08675835d4b81015ee368a268b";
      hash = "sha256-UBaOSKc+Z/1HDgct5Je5r/FHtzgo+yHMR7Sa5i8M9jU=";
    };
  };
in
{
  programs.nixvim.extraPlugins = [
    {
      plugin = telescope-send-to-harpoon2;
      optional = false;
    }
  ];

  programs.nixvim.plugins = {
    lz-n = {
      plugins = [
        {
          __unkeyed-1 = "telescope-send-to-harpoon2";
          event = ["VimEnter"];
        }
      ];
    };
  };

  programs.nixvim.plugins.telescope = {
    enabledExtensions = [ "send_to_harpoon" ];
    settings.defaults.mappings.i = {
      "<C-e>" = {
        __raw = "require'telescope'.extensions.send_to_harpoon.actions.send_selected_to_harpoon";
      };
    };
  };
}
