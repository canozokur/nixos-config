{ config, ... }:
{
  services.consul = {
    enable = true;
    webUi = true;
    interface.bind = "${config._meta.networks.internalIP}";
  };

  _meta.dnsConfigurations = [{
    ip = config._meta.networks.internalIP;
    domain = "consul.lan";
  }];
}
