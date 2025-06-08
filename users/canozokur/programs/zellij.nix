{ ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    attachExistingSession = true;
  };

  # see: https://github.com/nix-community/home-manager/pull/4665#issuecomment-1822999684
  # current KDL generator is not good enough to have the whole config here
  xdg.configFile."zellij/config.kdl".source = ./zellij/config.kdl;
}
