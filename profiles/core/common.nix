{ inputs, pkgs, ... }:
let
  secretsPath = builtins.toString inputs.nix-secrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    # custom modules
    ../../modules
  ];

  # common overlays go here
  nixpkgs.overlays = [
    (final: prev: {
      zjstatus = inputs.zjstatus.packages.${prev.system}.default;
    })
  ];

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      "network/secrets/home-wifi/psk" = { };
      "network/secrets/home-wifi-5g/psk" = { };
      "passwords/canozokur".neededForUsers = true;
    };
  };
  # enable all firmware regardless of license
  hardware.enableAllFirmware = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [ "root" ];

  users.mutableUsers = false;
  time.timeZone = "Europe/Helsinki";

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout=30
    '';
    wheelNeedsPassword = false;
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    file
    binutils
  ];

  environment.enableAllTerminfo = true;

  # enable docker
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
      persistent = true;
    };
  };
}
