{ lib, options, ... }:
{
  # Define _meta options
  options._meta = with lib; {
    dnsConfigurations = mkOption {
      description = "List of DNS records associated with this host. These record will be added to pihole as static hosts.";
      default = [ ];
      type = types.listOf (
        types.submodule {
          options = {
            ip = mkOption {
              type = types.str;
              description = "The external IP address.";
            };
            domain = mkOption {
              type = types.str;
              description = "The domain name (e.g. 'testing.lan').";
            };
          };
        }
      );
    };

    nginx = {
      vhosts = mkOption {
        description = "Nginx vhosts contributed by this host to the fleet proxy.";
        default = { };
        type = options.services.nginx.virtualHosts.type;
      };

      upstreams = mkOption {
        description = "Nginx upstreams contributed by this host to the fleet proxy.";
        default = { };
        type = options.services.nginx.upstreams.type;
      };
    };

    networks = mkOption {
      description = "External and internal IP addresses of this host";
      default = { };
      type = types.submodule {
        options = {
          externalIP =
            with types;
            mkOption {
              type = str;
              default = "";
              description = "The primary external address of this host";
            };
          internalIP =
            with types;
            mkOption {
              type = str;
              default = "";
              description = "The primary internal address of this host";
            };
          internalInterface =
            with types;
            mkOption {
              type = str;
              default = "";
              description = "The primary internal network interface of this host";
            };
          wiredAddresses =
            with types;
            mkOption {
              type = listOf str;
              default = [ ];
              description = "List of static IPs (i.e. 192.168.1.100/24) for the wired profile";
            };
        };
      };
    };

    services = {
      consulServer = lib.mkEnableOption "This host is a Consul Server";
      dnsServer = lib.mkEnableOption "This host is a DNS server";
      dhcpServer = lib.mkEnableOption "This host is a DHCP server";
      galera.clusterName = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "A unique Galera cluster name.";
      };
      mysql.instanceName = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Instance name of this MariaDB standalone server.";
      };
    };

    desktop = mkOption {
      description = "Desktop related settings";
      default = { };
      type = types.submodule {
        options = {
          hyprlandGPU = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Environment variables for Hyprland GPU settings";
          };
          waybarTemperaturePath = mkOption {
            type = types.str;
            default = "";
            description = "HWMon path in /sys/devices for waybar to display the temp";
          };
        };
      };
    };

    prometheus = mkOption {
      description = "Prometheus / node-exporter configuration for this host.";
      default = { };
      type = types.submodule {
        options = {
          enabledCollectors = mkOption {
            type = types.listOf types.str;
            default = [ "systemd" ];
            description = "Enabled node-exporter collectors";
          };
        };
      };
    };
  };

  # consul services
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
