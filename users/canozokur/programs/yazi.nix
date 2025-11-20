{ ... }:
{
  programs.yazi = {
    enable = true;
    settings = {
      tasks = {
        image_bound = [0 0];
      };
    };
  };
}
