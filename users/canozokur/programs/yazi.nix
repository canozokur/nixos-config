{ ... }:
{
  programs.yazi = {
    enable = true;
    settings = {
      tasks = {
        image_bound = [0 0];
      };
      mgr = {
        show_hidden = true;
      };
    };
  };
}
