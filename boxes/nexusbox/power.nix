{ ... }:
{
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
  };

  # power_save=true actually disables power saving config for some reason
  # and power_level=5 should max it out (hopefully?)
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=true power_level=5
  '';
}
