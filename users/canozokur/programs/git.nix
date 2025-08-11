{ config, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = "13416785+canozokur@users.noreply.github.com";
    userName = "canozokur";
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      format = "ssh";
      signByDefault = true;
    };
    extraConfig = {
      pull = { ff = "only"; };
      init = { defaultbranch = "main"; };
      push = { autosetupremote = true; };
      url."git@github.com:".insteadOf = "https://github.com/";
      core = {
        filemode = true;
        bare = false;
        logallrefupdates = true;
      };
    };
    difftastic = {
      enable = true;
      enableAsDifftool = true;
    };
    ignores = [
      ".aider*"
    ];
  };
}
