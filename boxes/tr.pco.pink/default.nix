{ config, inputs, ... }:
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
    networkmanager = {
      enable = true;
      dns = "default";
      ensureProfiles = {
        secrets.entries = [
          {
            file = config.sops.secrets."network/secrets/home-wifi/psk".path;
            key = "psk";
            matchId = "home-wifi";
            matchSetting = "802-11-wireless-security";
            matchType = "802-11-wireless";
          }
        ];
        profiles = {
          wired = {
            connection = {
              id = "wired";
              permissions = "";
              type = "802-3-ethernet";
              interface-name = "ens18";
              autoconnect = true;
            };
            ipv4 = {
              method = "manual";
              addresses = "176.53.96.161/24";
              gateway = "176.53.96.1";
              dns = "1.1.1.1;1.0.0.1";
            };
          };
        };
      };
    };
  };

  _meta = {
    networks = {
      internalIP = "176.53.96.161";
      externalIP = "176.53.96.161";
      internalInterface = "ens18";
    };
    services = {
      consulServer = false;
    };
    prometheus.enabledCollectors = [
      "systemd"
    ];
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
