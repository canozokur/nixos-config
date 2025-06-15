{ nix-secrets, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = "SetEnv TERM=xterm";
    matchBlocks = nix-secrets.ssh.matchBlocks;
  };
}
