{ lib, config, ... }:
{
  imports = [
    # import common settings for all profiles
    ./common.nix
  ];

  services.blueman.enable = lib.mkIf (config.hardware.bluetooth.enable == true) true;
}
