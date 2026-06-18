{ inputs, config, ... }:
{

  # use a pre-generated ssh key for remotebuilds
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.secrets."ssh/keys/remotebuild-client" = {
    path = "/etc/ssh/remote_build_client_ed25519_key";
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    buildMachines = [
      {
        hostName = "homebox";
        protocol = "ssh-ng";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        sshUser = "remotebuild";
        sshKey = config.sops.secrets."ssh/keys/remotebuild-client".path;
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
        "ssh-ng://remotebuild@homebox"
      ];

      fallback = true;
    };
  };
}
