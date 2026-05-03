{ ... }:
{
  plugins = {
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

  extraConfigLua = ''
    require('dap').listeners.after.event_initialized['dapui_config'] = require('dapui').open
    require('dap').listeners.before.event_terminated['dapui_config'] = require('dapui').close
    require('dap').listeners.before.event_exited['dapui_config'] = require('dapui').close
  '';

  keymaps = [
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
}
