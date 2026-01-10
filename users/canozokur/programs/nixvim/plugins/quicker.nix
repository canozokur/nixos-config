{ ... }:
{
  plugins = {
    quicker = {
      enable = true;
      lazyLoad.settings.event = "FileType qf";
      settings = {
        keys = [
          {
            __unkeyed-1 = ">";
            __unkeyed-2 = "<cmd>lua require('quicker').toggle_expand()<CR>";
            desc = "Expand quickfix content";
          }
        ];
      };
    };
  };
}
