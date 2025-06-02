{ ... }:
{
  programs.nixvim.filetype = {
    pattern = {
      ".*/templates/.*%.yaml" = "helm";
    };
  };
}
