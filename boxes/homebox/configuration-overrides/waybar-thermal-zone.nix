{ ... }:
{
  config.hostSpecificOverrides = {
    programs.waybar.settings.mainBar.temperature.hwmon-path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input";
  };
}
