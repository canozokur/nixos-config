{ config, pkgs, ... }:
{
  imports = [
    ./capabilities/desktop.nix
    ./capabilities/coding.nix
    ../programs/vault.nix
  ];

  home.packages = with pkgs; [
    slack
  ];

  sops.secrets = {
    "unity-ai/api-key" = { };
    "unity-ai/baseurl" = { };
  };

  programs.nixvim.codecompanion = {
    adapters.custom_litellm = {
      type = "openai_compatible";
      apiKeyFile = config.sops.secrets."unity-ai/api-key".path;
      baseUrlFile = config.sops.secrets."unity-ai/baseurl".path;
      chatUrl = "/v1/chat/completions";
      model = "claude-opus-4-7";
    };
    defaultAdapter = "custom_litellm";
  };
}
