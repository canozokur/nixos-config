{ config, ... }:
{
  users.users.canozokur = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "dialout"
    ];
    createHome = true;
    hashedPasswordFile = config.sops.secrets."passwords/canozokur".path;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCk/uh6KjUB8wNwLawPdZyJ9AcN0aHjspZuukQcsI773s1ghy5U4Wlhx+FEeUsZzBEcMRGf8bZzyvhb57H8B/lA7W4wz9TfLHAPu2OqE2Lu8anxqebCmjSchvfckefHe7B/J0oUtyhqOyw5+DPvi8HSbIh5/oxQqwweUGl9nqmhLZj883fnGYGsvoSKHmkuh2PpSLZQng8cGGAR7/1wakIR8XWMmDt7k+AYrTuSihJLpgiWgexZ2mTcVuEpJhhi2nC/0lKly4Czvg/EuKHDMocV0dJz8/1CVxlpO7oQvPMx4x1aPZQqUNYqmv60Voc33xM4Qg7dv4I371O/tOHAew7V queljin@thebox"
    ];
  };

  # required for devenv
  nix.settings.trusted-users = [ "canozokur" ];
}
