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
        };
      };
    };

    # Image payload
    buildImage = lib.mkEnableOption "This host exports an image to build";
  };
}
