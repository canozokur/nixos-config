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

  programs.aider = {
    model = "openai/claude-opus-4-6-ent-ai";
    weakModel = "openai/claude-haiku-4-5-20251001-ent-ai";
    apiKeyPlaceholder = config.sops.placeholder."unity-ai/api-key";
    baseUrlPlaceholder = config.sops.placeholder."unity-ai/baseurl";
  };
}
