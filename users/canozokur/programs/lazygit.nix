{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      promptToReturnFromSubprocess = false;
      git.overrideGpg = true;
    };
  };
}
