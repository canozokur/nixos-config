{ ... }:
{
  programs.powerline-go = {
    enable = true;
    modules = [
      "termtitle"
      "git"
      "aws"
      "kube"
      "terraform-workspace"
      "venv"
      "newline"
      "cwd"
      "perms"
      "jobs"
      "exit"
      "nix-shell"
    ];

    settings = {
      cwd-max-depth = 3;
      cwd-mode = "fancy";
      numeric-exit-codes = true;
      shell = "bash";
    };
  };
}
