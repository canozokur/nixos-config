{ config, ... }:
{
  sops.secrets."nix/access-tokens" = { };

  nix.extraOptions = ''
    !include ${config.sops.secrets."nix/access-tokens".path}
  '';
}
