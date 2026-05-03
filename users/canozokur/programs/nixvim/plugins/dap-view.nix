{ ... }:
{
  plugins = {
    dap-view = {
      enable = true;
      settings = {
        winbar = {
          show = true;
          controls.enabled = true;
        };
        auto_toggle = true;
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<F7>";
      action = ":DapViewToggle";
      options = {
        desc = "Toggle dap-view";
      };
    }
  ];
}
