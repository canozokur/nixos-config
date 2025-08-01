{ inputs, ... }:
{
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        duration = "15m";
        mode = "center";
        path = "${inputs.wallpapers}";
      };
    };
  };
}
