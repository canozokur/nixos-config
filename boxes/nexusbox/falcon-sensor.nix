{ inputs, config, ... }:
let
  secretsPath = builtins.toString inputs.nix-secrets;
in
{
  sops.secrets."falcon-sensor/cid" = {};

  falconSensor = rec {
    enable = true;
    version = "7.20.0-17308";
    arch = "amd64";
    cid = config.sops.secrets."falcon-sensor/cid".path;
    debFile = "${secretsPath}/binary/falcon-sensor_${version}_${arch}.deb";
  };
}
