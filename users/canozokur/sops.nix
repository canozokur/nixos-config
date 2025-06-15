{ nix-secrets, ... }:
let
  secretsPath = builtins.toString nix-secrets;
in
{
  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;
    age = {
      keyFile = "/home/canozokur/.config/sops/age/keys.txt";
      generateKey = false;
      sshKeyPaths = [ "/home/canozokur/.ssh/id_ed25519" ];
    };
    gnupg.sshKeyPaths = [];

    secrets = {
      "ssh/keys" = {
        path = "/home/canozokur/.ssh/id_ed25519";
      };
    };
  };
}
