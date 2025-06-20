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
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers decorations";
        syntax-theme = "zenburn";
        whitespace-error-style = "22 reverse";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    };
  };
}
