{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.box.build.remoteBuilders;
in
{
  # use a pre-generated ssh key for remotebuilds
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.secrets."ssh/keys/remotebuild-client" = {
    path = "/etc/ssh/remote_build_client_ed25519_key";
  };

  programs.ssh.knownHosts."guild" = {
    hostNames = [
      "guild"
      "guild.ts.pco.pink"
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMquedk0M5HiAoYVBvNbTg0ye3qSBJ3pcPZL9TAdPYe9";
  };

  nix = lib.mkIf (cfg != [ ]) {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    buildMachines = map (b: {
      hostName = b.host;
      protocol = "ssh-ng";
      inherit (b) systems maxJobs speedFactor supportedFeatures;
      sshUser = "remotebuild";
      sshKey = config.sops.secrets."ssh/keys/remotebuild-client".path;
    }) cfg;

    distributedBuilds = true;

    extraOptions = ''
      builders-use-substitutes = true
    '';

    optimise = {
      automatic = true;
    };

    settings = {
      connect-timeout = 15;

      experimental-features = [
        "flakes"
        "nix-command"
      ];

      extra-substituters = map (b: "ssh-ng://remotebuild@${b.host}") cfg;

      fallback = true;
    };
  };
}
