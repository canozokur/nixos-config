{ ... }:
{
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCk/uh6KjUB8wNwLawPdZyJ9AcN0aHjspZuukQcsI773s1ghy5U4Wlhx+FEeUsZzBEcMRGf8bZzyvhb57H8B/lA7W4wz9TfLHAPu2OqE2Lu8anxqebCmjSchvfckefHe7B/J0oUtyhqOyw5+DPvi8HSbIh5/oxQqwweUGl9nqmhLZj883fnGYGsvoSKHmkuh2PpSLZQng8cGGAR7/1wakIR8XWMmDt7k+AYrTuSihJLpgiWgexZ2mTcVuEpJhhi2nC/0lKly4Czvg/EuKHDMocV0dJz8/1CVxlpO7oQvPMx4x1aPZQqUNYqmv60Voc33xM4Qg7dv4I371O/tOHAew7V queljin@thebox"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxRZiGQpiVL+EVnfAEOozMLQXYCRBq7+xA2Sf7UcNtI root@nixos"
    ];
  };

  users.groups.remotebuild = {};

  nix = {
    nrBuildUsers = 64;
    settings = {
      trusted-users = [ "remotebuild" ];

      min-free = 10 * 1024 * 1024;
      max-free = 200 * 1024 * 1024;

      max-jobs = "auto";
      cores = 0;
    };
  };

  # enable builds for aarch64
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
  };
}
