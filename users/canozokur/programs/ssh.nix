{ inputs, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 10;
    extraConfig = "SetEnv TERM=xterm";
    matchBlocks = inputs.nix-secrets.ssh.matchBlocks;
  };
}
