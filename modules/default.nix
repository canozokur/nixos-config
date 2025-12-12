{ lib, ... }:
{
  imports = [
    ./falcon-sensor
  ];

  # Define _meta options
  options._meta = with lib; {
    dnsConfiguration = mkOption {
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

    # Image payload
    buildImage = lib.mkEnableOption "This host exports an image to build";
  };
}
