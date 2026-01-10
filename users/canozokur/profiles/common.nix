{
  inputs,
  config,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  secretsPath = builtins.toString inputs.nix-secrets;
  cfgHome = config.xdg.configHome;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../programs/git.nix
    ../programs/ssh-agent.nix
    ../programs/ssh.nix
    ../programs/nix.nix
    ../programs/lazygit.nix
    ../programs/yazi.nix
  ];

  home.packages = with pkgs; [
    fzf
    tree
    jq
    htop
    ripgrep
    watch
  ];

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;
    age = {
      keyFile = "${cfgHome}/sops/age/keys.txt";
      generateKey = false;
      sshKeyPaths = [ "${homeDir}/.ssh/id_ed25519" ];
    };
    gnupg.sshKeyPaths = [ ];
    secrets = {
      "ssh/keys/default" = {
        path = "${homeDir}/.ssh/id_ed25519";
      };
      "ssh/keys/queljin" = {
        path = "${homeDir}/.ssh/queljin";
      };
    };
  };

  # allow unfree in our shell
  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

  home.stateVersion = "24.05";
}
