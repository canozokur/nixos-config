{ ... }:
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y"; # updated versions use y instead of yy
    settings = {
      tasks = {
        image_bound = [
          0
          0
        ];
      };
      mgr = {
        show_hidden = true;
      };
    };
  };
}
