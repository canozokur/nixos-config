{ ... }:
{
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
  };
}
