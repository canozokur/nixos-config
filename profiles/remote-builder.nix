{ lib, config, ... }:
{
  users.users.remotebuild = {
    isNormalUser = lib.mkIf config.virtualisation.docker.rootless.enable true;
    isSystemUser = lib.mkIf (!config.virtualisation.docker.rootless.enable) true;
    group = "remotebuild";
    useDefaultShell = true;
    extraGroups = [
      "docker"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxRZiGQpiVL+EVnfAEOozMLQXYCRBq7+xA2Sf7UcNtI remotebuild-client@nixos"
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
