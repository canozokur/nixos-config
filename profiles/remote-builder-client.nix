{ ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    buildMachines = [
      {
        hostName = "192.168.1.7";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];

    distributedBuilds = true;

    extraOptions = ''
      builders-use-substitutes = true
    '';

    optimise = {
      automatic = true;
    };

    settings = {
      connect-timeout = 5;

      experimental-features = [
        "flakes"
        "nix-command"
      ];

      extra-substituters = [
        "ssh-ng://192.168.1.7"
      ];

      fallback = true;
    };
  };
}
