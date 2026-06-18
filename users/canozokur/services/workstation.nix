{ config, pkgs, ... }:
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

  programs.aider = {
    model = "openai/claude-opus-4-6-ent-ai";
    weakModel = "openai/claude-haiku-4-5-20251001-ent-ai";
    apiKeyPlaceholder = config.sops.placeholder."unity-ai/api-key";
    baseUrlPlaceholder = config.sops.placeholder."unity-ai/baseurl";
  };
}
