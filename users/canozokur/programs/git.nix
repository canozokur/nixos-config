{ config, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        email = "13416785+canozokur@users.noreply.github.com";
        name = "canozokur";
      };
      pull = {
        ff = "only";
      };
      init = {
        defaultbranch = "main";
      };
      push = {
        autosetupremote = true;
      };
      url."git@github.com:".insteadOf = "https://github.com/";
      core = {
        filemode = true;
        bare = false;
        logallrefupdates = true;
      };
    };
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      format = "ssh";
      signByDefault = true;
    };
    ignores = [
      ".aider*"
      ".devenv*"
      "devenv.local.nix"
    ];
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
  };
}
