{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
      };
      timeout = 30; # large t/o to make sure we get a screen on boot at home
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 1935 ];
    };
    hostName = "tr";
    domain = "pco.pink";
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks."10-ens18" = {
    matchConfig.Name = "ens18";
    address = [ "176.53.96.161/24" ];
    gateway = [ "176.53.96.1" ];
    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  services.consul.server.enable = false;
  services.node-exporter.enabledCollectors = [
    "systemd"
  ];

  box.networking = {
    internalIP = "176.53.96.161";
    externalIP = "176.53.96.161";
    internalInterface = "ens18";
    tailnet.advertiseExitNode = true;
  };

  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  system.stateVersion = "26.05";
}
