{ config, inputs, pkgs, ... }:
let
  secretsPath = builtins.toString inputs.nix-secrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../../modules
  ];

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
  # enable all firmware regardless of license
  hardware.enableAllFirmware = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" ];

  users.mutableUsers = false;

  nix.optimise = {
    automatic = true;
    dates = ["03:45"];
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout=30
    '';
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    greetd.greetd
    greetd.tuigreet
    file
    binutils
  ];

  services.greetd = {
    enable = true;
    restart = true;
    vt = 7;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
      };
    };
  };

  boot.consoleLogLevel = 0;

  security.polkit.enable = true; # required for sway
  security.pam.services.swaylock = {}; # required for swaylock

  # enable docker
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
      persistent = true;
    };
  };

  # swaync & i3status-rs requires dconf to pause notifications
  programs.dconf.enable = true;

  # TODO: this could be moved to a library function to create the secrets config
  # i.e. makeNMProfile "conn-id" { .. other config ... }
  sops.secrets."network/secrets/home-wifi/psk" = {};
  sops.secrets."network/secrets/home-wifi-5g/psk" = {};
  networking.networkmanager.ensureProfiles = {
    secrets.entries = [
      {
        file = config.sops.secrets."network/secrets/home-wifi-5g/psk".path;
        key = "psk";
        matchId = "home-wifi-5g";
        matchSetting = "802-11-wireless-security";
        matchType = "802-11-wireless";
      }
      {
        file = config.sops.secrets."network/secrets/home-wifi/psk".path;
        key = "psk";
        matchId = "home-wifi";
        matchSetting = "802-11-wireless-security";
        matchType = "802-11-wireless";
      }
    ];
    profiles = {
      home-wifi-5g = {
        connection = {
          id = "home-wifi-5g";
          type = "wifi";
          autoconnect = true;
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "disabled";
        };
        wifi = {
          mode = "infrastructure";
          ssid = inputs.nix-secrets.network.home-wifi-5g.ssid;
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
        };
      };
      home-wifi = {
        connection = {
          id = "home-wifi";
          type = "wifi";
          autoconnect = "false";
        };
        wifi = {
          mode = "infrastructure";
          ssid = inputs.nix-secrets.network.home-wifi.ssid;
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "auto";
        };
      };
      office-wifi-enterprise = {
        connection = {
          id = "office-wifi-enterprise";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = inputs.nix-secrets.network.office-wifi-enterprise.ssid;
        };
        wifi-security = {
          key-mgmt = "wpa-eap";
        };
        "802-1x" = {
          eap = "peap";
          identity = "dummy";
          password = "dummy";
          phase2-auth = "mschapv2";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "auto";
        };
      };
    };
  };
}
