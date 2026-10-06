{ pkgs, ... }:
{
  imports = [
    ./base/desktop.nix
    ./base/coding.nix
    ../programs/vault.nix
  ];

  home.packages = with pkgs; [
    slack
  ];

  sops.secrets = {
    "unity-ai/api-key" = { };
    "unity-ai/baseurl" = { };
    "claude-code/oauth-token" = { };
  };
}
