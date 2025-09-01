{ ... }:
{
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
  };

  # power_save=true actually disables power saving config for some reason
  # and power_level=5 should max it out (hopefully?)
  # for power_scheme explanation see:
  # https://wiki.debian.org/iwlwifi#WiFi interruptions on Intel AX
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=true power_level=5 power_scheme=1
  '';
}
