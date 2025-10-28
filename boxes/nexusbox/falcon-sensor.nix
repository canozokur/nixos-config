{ inputs, config, ... }:
let
  secretsPath = builtins.toString inputs.nix-secrets;
in
{
  sops.secrets."falcon-sensor/cid" = {};
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
}
