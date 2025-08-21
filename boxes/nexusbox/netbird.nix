{ pkgs, ... }:
{
  services.netbird = {
    enable = true;
    useRoutingFeatures = "client";
    ui.enable = true;
  };
  environment.systemPackages = [ pkgs.netbird-ui ];
}
