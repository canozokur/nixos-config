{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = false;
    };
  };

  networking = {
    firewall = {
      enable = true;
    };
    hostName = "guild";
    domain = "pco.pink";
    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        wired = {
          connection = {
            id = "wired";
            permissions = "";
            type = "802-3-ethernet";
            interface-name = "enp0s6";
            autoconnect = true;
          };
          ipv4 = {
            method = "manual";
            addresses = "10.0.253.251/16";
            gateway = "10.0.0.1";
            dns = "1.1.1.1;1.0.0.1";
          };
        };
      };
    };
  };

  services.consul.server.enable = false;
  services.node-exporter.enabledCollectors = [
    "systemd"
  ];

  box.networking = {
    internalIP = "10.0.253.251";
    externalIP = "82.70.46.56";
    internalInterface = "enp0s6";
    tailnet.advertiseExitNode = true;
  };

  system.stateVersion = "26.05";
}
