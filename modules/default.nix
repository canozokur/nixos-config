{ lib, ... }:
{
  imports = [
    ./falcon-sensor
  ];

  # Define _meta options
  options._meta = with lib; {
    dnsConfigurations = mkOption {
      description = "List of DNS records associated with this host. These record will be added to pihole as static hosts.";
      default = [];
      type = types.listOf (types.submodule {
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
      });
    };

    networks = mkOption {
      description = "External and internal IP addresses of this host";
      default = {};
      type = types.submodule {
        options = {
          externalIP = with types; mkOption { type = str; default = ""; description = "The primary external address of this host"; };
          internalIP = with types; mkOption { type = str; default = ""; description = "The primary internal address of this host"; };
          internalInterface = with types; mkOption { type = str; default = ""; description = "The primary internal network interface of this host"; };
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
    };

    # Image payload
    buildImage = lib.mkEnableOption "This host exports an image to build";

    desktop = mkOption {
      description = "Desktop related settings";
      default = {};
      type = types.submodule {
        options = {
          hyprlandGPU = mkOption { type = types.listOf types.str; default = []; description = "Environment variables for Hyprland GPU settings"; };
          waybarTemperaturePath = mkOption { type = types.str; default = ""; description = "HWMon path in /sys/devices for waybar to display the temp"; };
        };
      };
    };

    prometheus = mkOption {
      description = "Consul configuration";
      default = {};
      type = types.submodule {
        options = {
          enabledCollectors = mkOption { type = types.listOf types.str; default = [ "systemd" ]; description = "Enabled node-exporter collectors"; };
        };
      };
    };
  };

  # consul services
  options.services.consul.agentServices = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [];
    description = "List of services to register with the local Consul agent.";
  };
}
