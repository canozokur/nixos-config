{ ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
      enabledCollectors = [ "systemd" ];
      disabledCollectors = [ "zfs" ];
    };
  };

  _meta.scrapeTarget = true;
}
