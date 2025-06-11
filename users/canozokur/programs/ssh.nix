{ ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "aur.archlinux.org" = {
        identityFile = "~/ssh/aur";
        user = "aur";
      };
      "hc-linode" = {
        user = "canozokur";
        identityFile = "~/ssh/queljin";
      };
      "*" = {
        setEnv = {
          TERM = "xterm";
        };
      };
    };
  };
}
