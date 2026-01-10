{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "nvim-startuptime";
      src = pkgs.fetchFromGitHub {
        owner = "dstein64";
        repo = "vim-startuptime";
        rev = "b6f0d93f6b8cf6eee0b4c94450198ba2d6a05ff6";
        hash = "sha256-0YLDkU1y89O5z7tgxaH5USQpJDfTuN0fsPJOAp6pa5Y=";
      };
    })
  ];

  globals = {
    startuptime_exe_path = "nvim";
  };
}
