{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "telescope-send-to-harpoon2";
      src = pkgs.fetchFromGitHub {
          owner = "TheNemoNemesis";
          repo = "telescope-send-to-harpoon2.nvim";
          rev = "eb457d3485056b08675835d4b81015ee368a268b";
          hash = "sha256-UBaOSKc+Z/1HDgct5Je5r/FHtzgo+yHMR7Sa5i8M9jU=";
      };
    })
  ];

  programs.nixvim.plugins.telescope.enabledExtensions = [ "send_to_harpoon" ];
}
