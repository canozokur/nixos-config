{ inputs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 10;
        ServerAliveCountMax = 3;
        Compression = "no";
        HashKnownHosts = "no";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        ForwardAgent = "no";
        SetEnv.TERM = "xterm";
      };
    }
    // inputs.nix-secrets.ssh.matchBlocks;
  };
}
