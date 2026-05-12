{ ... }:
{
  plugins.actions-preview = {
    enable = true;

    settings = {
      telescope = {
        layout_strategy = "vertical";
        layout_config = {
          width = 0.8;
          height = 0.9;
          prompt_position = "top";
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
      key = "<leader>ca";
      action.__raw = "require('actions-preview').code_actions";
      options.desc = "Code Actions (Preview)";
    }
  ];
}
