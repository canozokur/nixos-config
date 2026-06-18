{
  lib,
  ...
}:
{
  # Host identity — these options describe *this* host, not a service.
  # Set in `boxes/${boxName}/default.nix`. Read by service modules and by
  # home-manager via `osConfig`.
  options.box = {
    networking = {
      externalIP = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The primary external address of this host.";
      };
      internalIP = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The primary internal address of this host.";
      };
      internalInterface = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The primary internal network interface of this host.";
      };
      wiredAddresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of static IPs (e.g. 192.168.1.100/24) for the wired profile.";
      };
    };

    desktop = {
      hyprlandGPU = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Environment variables for Hyprland GPU settings.";
      };
      waybarTemperaturePath = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "HWMon path in /sys/devices for waybar to display the temp.";
      };
    };
  };

  options.services.node-exporter.enabledCollectors = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "systemd" ];
    description = "Enabled node-exporter collectors.";
  };

  options.services.mysql = {
    galera.clusterName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "A unique Galera cluster name.";
    };
    instanceName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Instance name of this MariaDB standalone server.";
    };
  };

  options.services.pihole = {
    dnsServer = lib.mkEnableOption "This host runs the DNS server (Pi-hole)";
    dhcpServer = lib.mkEnableOption "This host runs the DHCP server (Pi-hole)";
    extraStaticHosts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            ip = lib.mkOption {
              type = lib.types.str;
              description = "The IP address for the static host.";
            };
            domain = lib.mkOption {
              type = lib.types.str;
              description = "The domain name for the static host.";
            };
          };
        }
      );
      default = [ ];
      description = "Static DNS entries to register on the DNS server.";
    };
  };

  # Contribs must be declared on every host that publishes vhosts/upstreams
  # (e.g. emby/nzbget glue files run on hosts that don't load reverse-proxy.nix).
  options.services.reverseProxy.contribs = lib.mkOption {
    description = "Nginx vhost and upstream contributions from each service.";
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        vhosts = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = { };
          description = "Nginx vhosts contributed by this service.";
        };
        upstreams = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = { };
          description = "Nginx upstreams contributed by this service.";
        };
      };
    });
    default = { };
  };
}
