{ ... }:
{
  plugins = {
    dap = {
      enable = true;
      adapters = {
        servers = {
          delve = {
            host = "127.0.0.1";
            port = "\${port}";
            executable = {
              command = "dlv";
              args = [
                "dap"
                "-l"
                "127.0.0.1:\${port}"
                "--log"
                "--log-output=dap"
              ];
            };
          };
        };
      };
      configurations = {
        go = [
          {
            type = "delve";
            name = "Debug Package";
            request = "launch";
            program = "\${fileDirname}";
          }
          {
            type = "delve";
            name = "Debug";
            request = "launch";
            program = "\${file}";
          }
          {
            type = "delve";
            name = "Debug test";
            request = "launch";
            mode = "test";
            program = "\${file}";
          }
          {
            type = "delve";
            name = "Debug test (go.mod)";
            request = "launch";
            mode = "test";
            program = "./\${relativeFileDirname}";
          }
          {
            type = "delve";
            name = "Debug Project (Root)";
            request = "launch";
            program = "\${workspaceFolder}";
            cwd = "\${workspaceFolder}";
          }
        ];
      };
    };
    dap.signs.dapBreakpoint.text = "";
  };

  keymaps = [
    {
      mode = "n";
      key = "<F5>";
      action.__raw = ''
        function()
          require('dap').continue()
        end
      '';
    }
    {
      mode = "n";
      key = "<F1>";
      action.__raw = ''
        function()
          require('dap').step_into()
        end
      '';
    }
    {
      mode = "n";
      key = "<F2>";
      action.__raw = ''
        function()
          require('dap').step_over()
        end
      '';
    }
    {
      mode = "n";
      key = "<F3>";
      action.__raw = ''
        function()
          require('dap').step_out()
        end
      '';
    }
    {
      mode = "n";
      key = "<leader>b";
      action.__raw = ''
        function()
          require('dap').toggle_breakpoint()
        end
      '';
    }
    {
      mode = "n";
      key = "<leader>B";
      action.__raw = ''
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end
      '';
    }
  ];
}
