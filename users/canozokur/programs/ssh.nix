{ nix-secrets, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 10;
    extraConfig = "SetEnv TERM=xterm";
    matchBlocks = nix-secrets.ssh.matchBlocks;
  };
}
