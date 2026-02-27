{ pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
    package = pkgs.sunshine.override {
      boost = pkgs.boost187;
    };
  };
}
