{
  inputs,
  pkgs,
  config,
  ...
}:
let
  gpclient-connect = pkgs.writeScriptBin "gpclient-connect" ''
    old_resolv=$(</etc/resolv.conf)

    trap restore_dns SIGHUP SIGINT SIGQUIT SIGABRT SIGALRM SIGTERM

    restore_dns()
    {
      echo "''${old_resolv}" > /etc/resolv.conf
    }

    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
    fi
    ${pkgs.gpclient}/bin/gpclient --fix-openssl connect ${inputs.nix-secrets.network.office-vpn-address}
  '';

  secretsPath = builtins.toString inputs.nix-secrets;
in
{
  imports = [
    inputs.kolide-launcher.nixosModules.kolide-launcher
  ];

  environment.systemPackages = with pkgs; [
    gpauth
    gpclient
    gpclient-connect
    netbird-ui
  ];

  sops.secrets = {
    "falcon-sensor/cid" = { };
    "kolide-k2/secret" = { };
  };

  services.netbird = {
    enable = true;
    useRoutingFeatures = "client";
    ui.enable = true;
  };

  # allow dynamically linked executables to run
  # required for Kolide integration
  programs.nix-ld.enable = true;

  falconSensor = rec {
    enable = true;
    version = "7.30.0-18306";
    arch = "amd64";
    cid = config.sops.secrets."falcon-sensor/cid".path;
    debFile = "${secretsPath}/binary/falcon-sensor_${version}_${arch}.deb";
  };

  environment.etc."kolide-k2/secret" = {
    mode = "0600";
    source = config.sops.secrets."kolide-k2/secret".path;
  };

  services.kolide-launcher.enable = true;
}
