{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ aider-chat ];

  sops.secrets = {
    "unity-ai/api-key" = { };
    "unity-ai/baseurl" = { };
  };

  sops.templates.".aider.conf.yml" = {
    content = ''
      model: openai/anthropic.claude-sonnet-4-20250514-v1:0
      weak-model: openai/anthropic.claude-3-5-haiku-20241022-v1
      show-model-warnings: false

      api-key:
        - openai=${config.sops.placeholder."unity-ai/api-key"}

      set-env:
        - OPENAI_API_BASE=${config.sops.placeholder."unity-ai/baseurl"}

      dark-mode: true
      gitignore: false
      analytics-disable: true
      vim: true
      edit-format: "ask"
    '';
    path = config.home.homeDirectory + "/.aider.conf.yml";
  };
}
