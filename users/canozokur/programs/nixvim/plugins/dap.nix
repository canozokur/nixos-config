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
              args = [ "dap" "-l" "127.0.0.1:\${port}" "--log" "--log-output=dap" ];
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
        ];
      };
    };
    dap.signs.dapBreakpoint.text = "";
    dap-ui = {
      enable = true;
      settings = {
        icons = {
          expanded = "󰜮";
          collapsed = "󰜴";
          current_frame = "*";
        };

        controls = {
          icons = {
            pause = "";
            play = "";
            step_into = "";
            step_over = "";
            step_out = "";
            step-back = "";
            run_last = "";
            terminate = "";
            disconnect = "";
          };
        };
      };
    };
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
    {
      mode = "n";
      key = "<F7>";
      action.__raw = ''
        function()
          require('dapui').toggle()
        end
      '';
      options = {
        desc = "Debug: See last session result.";
      };
    }
  ];

  extraConfigLua = ''
    require('dap').listeners.after.event_initialized['dapui_config'] = require('dapui').open
    require('dap').listeners.before.event_terminated['dapui_config'] = require('dapui').close
    require('dap').listeners.before.event_exited['dapui_config'] = require('dapui').close
  '';
}
