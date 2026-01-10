{ ... }:
{
  config.hostSpecificOverrides = {
    programs.waybar.settings.mainBar.temperature.hwmon-path =
      "/sys/devices/platform/PNP0C14:07/wmi_bus/wmi_bus-PNP0C14:07/8A42EA14-4F2A-FD45-6422-0087F7A7E608/hwmon/hwmon3/temp1_input";
  };
}
