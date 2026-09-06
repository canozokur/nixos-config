{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = true;
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
      dns = "default";
    };
  };

  services.consul.server.enable = false;
  services.node-exporter.enabledCollectors = [
    "systemd"
  ];

  # box.networking = {
  #   internalIP = "";
  #   externalIP = "";
  #   internalInterface = "";
  # };

  system.stateVersion = "26.05";
}
