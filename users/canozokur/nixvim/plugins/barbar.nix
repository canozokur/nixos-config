{ ... }:
{
  programs.nixvim.plugins = {
    barbar = {
      enable = true;
    };

    # barbar depends on web-devicons
    web-devicons.enable = true;
  };
}
