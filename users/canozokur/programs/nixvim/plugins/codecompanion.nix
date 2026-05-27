{
  pkgs,
  ...
}:
{
  plugins.treesitter.enable = true;

  extraPackages = [ pkgs.claude-agent-acp ];

  plugins.codecompanion = {
    enable = true;

    package = pkgs.vimPlugins.codecompanion-nvim.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm -rf $out/doc
      '';
    });

    settings = {
      adapters.acp.claude_code.__raw = ''
        function()
          return require("codecompanion.adapters").extend("claude_code", {})
        end
      '';

      interactions = {
        chat.adapter = "claude_code";
        inline.adapter = "claude_code";
        agent.adapter = "claude_code";
      };

      display.chat = {
        icons.chat_context = "📎️";
        fold_context = true;
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
}
