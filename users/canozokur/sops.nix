{ config, inputs, ... }:
let
  secretsPath = builtins.toString inputs.nix-secrets;
  homeDir = config.home.homeDirectory;
  cfgHome = config.xdg.configHome;
in
{
  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;
    age = {
      keyFile = "${cfgHome}/sops/age/keys.txt";
      generateKey = false;
      sshKeyPaths = [ "${homeDir}/.ssh/id_ed25519" ];
    };
    gnupg.sshKeyPaths = [];

    secrets = {
      "ssh/keys/default" = {
        path = "${homeDir}/.ssh/id_ed25519";
      };
      "ssh/keys/queljin" = {
        path = "${homeDir}/.ssh/queljin";
      };
    };
  };
}
