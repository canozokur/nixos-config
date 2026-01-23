{ inputs, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;

      wallpaper = [
      {
        monitor = "";
        path = "${inputs.wallpapers}";
        fit_mode = "cover";
        timeout = 60 * 15; # in seconds
      }
      ];
    };
  };
}
