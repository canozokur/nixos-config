{ inputs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 10;
        serverAliveCountMax = 3;
        compression = false;
        hashKnownHosts = false;
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        forwardAgent = false;
        extraOptions = {
          SetEnv = "TERM=xterm";
        };
      };
    } // inputs.nix-secrets.ssh.matchBlocks;
  };
}
