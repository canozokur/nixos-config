{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.aider;
in
{
  options.programs.aider = {
    enable = lib.mkEnableOption "the aider AI coding assistant";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.aider-chat-full;
      defaultText = lib.literalExpression "pkgs.aider-chat-full";
      description = "The aider package to install.";
    };

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Primary model identifier passed as `model:` in the aider config.";
    };

    weakModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Weak model identifier passed as `weak-model:` in the aider config.";
    };

    apiKeyPlaceholder = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Opaque placeholder string (typically `config.sops.placeholder."<name>"`)
        substituted into `api-key: - openai=<value>` at template render time.
        When null, no api-key line is emitted and no sops template is created.
      '';
    };

    baseUrlPlaceholder = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Opaque placeholder string substituted into
        `set-env: - OPENAI_API_BASE=<value>` at template render time.
      '';
    };

    darkMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable aider's dark-mode UI.";
    };

    vim = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable vim keybindings in aider.";
    };

    gitignore = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether aider should respect / modify `.gitignore`.";
    };

    analyticsDisable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to disable aider's analytics reporting.";
    };

    showModelWarnings = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether aider should print model-compatibility warnings.";
    };

    editFormat = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "ask";
      description = "Edit format aider should use (`whole`, `diff`, `ask`, ...).";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory + "/.aider.conf.yml";
      defaultText = lib.literalExpression ''config.home.homeDirectory + "/.aider.conf.yml"'';
      description = "Filesystem path the rendered aider config is symlinked to.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra YAML appended verbatim to the generated aider config. Useful for
        knobs not yet exposed as typed options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    sops.templates.".aider.conf.yml" = {
      path = cfg.configPath;
      content =
        let
          line = s: s + "\n";
          mkLine = key: value: line "${key}: ${value}";
          mkBoolLine = key: value: mkLine key (if value then "true" else "false");

          modelLines =
            lib.optionalString (cfg.model != null) (mkLine "model" cfg.model)
            + lib.optionalString (cfg.weakModel != null) (mkLine "weak-model" cfg.weakModel)
            + mkBoolLine "show-model-warnings" cfg.showModelWarnings;

          apiKeyBlock = lib.optionalString (cfg.apiKeyPlaceholder != null) ''

            api-key:
              - openai=${cfg.apiKeyPlaceholder}
          '';

          baseUrlBlock = lib.optionalString (cfg.baseUrlPlaceholder != null) ''

            set-env:
              - OPENAI_API_BASE=${cfg.baseUrlPlaceholder}
          '';

          uiLines =
            mkBoolLine "dark-mode" cfg.darkMode
            + mkBoolLine "gitignore" cfg.gitignore
            + mkBoolLine "analytics-disable" cfg.analyticsDisable
            + mkBoolLine "vim" cfg.vim
            + lib.optionalString (cfg.editFormat != null) (mkLine "edit-format" ''"${cfg.editFormat}"'');
        in
        modelLines
        + apiKeyBlock
        + baseUrlBlock
        + "\n"
        + uiLines
        + lib.optionalString (cfg.extraConfig != "") ("\n" + cfg.extraConfig);
    };
  };
}
