{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.codecompanion;

  mkAdapterLua =
    name: adapter:
    let
      envLines = lib.filter (l: l != null) [
        (lib.optionalString (adapter.baseUrlFile != null) ''url = "cmd:cat ${adapter.baseUrlFile}",'')
        (lib.optionalString (adapter.apiKeyFile != null) ''api_key = "cmd:cat ${adapter.apiKeyFile}",'')
        (lib.optionalString (adapter.chatUrl != null) ''chat_url = "${adapter.chatUrl}",'')
      ];

      envBlock = lib.optionalString (envLines != [ ]) ''
        env = {
          ${lib.concatStringsSep "\n" envLines}
        },
      '';

      schemaBlock = lib.optionalString (adapter.model != null) ''
        schema = {
          model = {
            default = "${adapter.model}",
          },
        },
      '';
    in
    ''
      function()
        return require("codecompanion.adapters").extend("${adapter.type}", {
          ${envBlock}${schemaBlock}
        })
      end
    '';
in
{
  options.codecompanion = {
    adapters = lib.mkOption {
      description = ''
        Attribute set of custom codecompanion HTTP adapters. Each entry is
        materialised into the `settings.adapters.http.<name>` Lua function.
        Values are intentionally typed as strings (not paths) so that runtime
        secret paths under `/run/user/<uid>/...` are not copied into the Nix
        store at evaluation time.
      '';
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            type = lib.mkOption {
              type = lib.types.str;
              default = "openai_compatible";
              description = "Upstream codecompanion adapter to extend.";
            };
            apiKeyFile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Path to a file containing the API key. Read at runtime via `cmd:cat`.";
            };
            baseUrlFile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Path to a file containing the base URL. Read at runtime via `cmd:cat`.";
            };
            chatUrl = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Chat endpoint suffix appended to the base URL (e.g. `/v1/chat/completions`).";
            };
            model = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Default model identifier for this adapter.";
            };
          };
        }
      );
    };

    defaultAdapter = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Name of the adapter (key in `codecompanion.adapters`) to use as the
        default for chat / inline / agent interactions. When null, no
        interaction overrides are emitted and codecompanion uses its own
        built-in defaults.
      '';
    };
  };

  config = {
    plugins.treesitter.enable = true;

    plugins.codecompanion = {
      enable = true;

      package = pkgs.vimPlugins.codecompanion-nvim.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm -rf $out/doc
        '';
      });

      settings = {
        adapters = lib.mkIf (cfg.adapters != { }) {
          http = lib.mapAttrs (name: adapter: { __raw = mkAdapterLua name adapter; }) cfg.adapters;
        };

        interactions = lib.mkIf (cfg.defaultAdapter != null) {
          chat.adapter = cfg.defaultAdapter;
          inline.adapter = cfg.defaultAdapter;
          agent.adapter = cfg.defaultAdapter;
        };

        prompt_library = {
          Coach = {
            strategy = "chat";
            description = "Acts as a mentor. Explains bugs and guides you without writing the code.";
            opts = {
              is_default = true;
              is_slash_cmd = true;
              alias = "coach";
            };
            prompts = [
              {
                role = "system";
                content = ''
                  You are an expert pair-programming partner and Socratic mentor. 
                  Your goal is to help the user learn and think critically. 

                  CRITICAL RULES:
                  1. Do NOT provide the exact, fully corrected code for the user's problem.
                  2. Point out the logical flaw or explain the underlying concept behind the issue.
                  3. Ask guiding questions to lead the user to the answer themselves.
                  4. If providing examples, use pseudocode or similar generic concepts, not the exact fix for their specific code.
                '';
              }
              {
                role = "user";
                content.__raw = ''
                  function()
                    local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                    local context = "I need help understanding or fixing my code.\n\n"
                    
                    if #diagnostics > 0 then
                      context = context .. "Here are the current LSP errors in my file:\n"
                      for _, diag in ipairs(diagnostics) do
                        context = context .. string.format("- Line %d: %s\n", diag.lnum + 1, diag.message)
                      end
                      context = context .. "\nBased on these errors and my code, what am I misunderstanding?"
                    else
                      context = context .. "There are no explicit LSP errors, but something is wrong or I want to improve this. Please review the provided selection."
                    end
                    return context
                  end
                '';
              }
            ];
          };
        };
      };
    };

    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cc";
        action = "<cmd>CodeCompanionChat Toggle<CR>";
        options = {
          desc = "Toggle AI Chat";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>co";
        action = "<cmd>CodeCompanion /coach<CR>";
        options = {
          desc = "Ask Coach";
          silent = true;
        };
      }
    ];
  };
}
