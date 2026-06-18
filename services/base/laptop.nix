{ ... }:
{
  # don't go to sleep on lid events
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
  };

}
