{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.openiscsi = {
    enable = true;
    discoverPortal = "192.168.0.100:3260";
    name = lib.mkDefault "iqn.2020-08.org.nixos.${config.system.name}:default";
    enableAutoLoginOut = true;
  };

  environment.systemPackages = with pkgs; [
    openiscsi
  ];
}
