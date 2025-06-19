{ config, ... }:
{
  sops.secrets."kolide-k2/secret" = {};

  environment.etc."kolide-k2/secret" = {
    mode = "0600";
    source = config.sops.secrets."kolide-k2/secret".path;
  };

  services.kolide-launcher.enable = true;
}
