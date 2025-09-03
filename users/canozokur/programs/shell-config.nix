{ pkgs, ... }:
{
  # we need this for alias completion in bash
  home.packages = with pkgs; [
    complete-alias
  ];

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "ignoreboth"
        "erasedups"
      ];
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -lav --ignore=..";   # show long listing of all except ".."
        l = "ls -lav --ignore=.?*";   # show long listing but no hidden dotfiles except "."
        apl = "ansible-playbook";
        cuti = ''
          curl -w '
          time_namelookup:  %{time_namelookup}
          time_connect:  %{time_connect}
          time_appconnect:  %{time_appconnect}
          time_pretransfer:  %{time_pretransfer}
          time_redirect:  %{time_redirect}
          time_starttransfer:  %{time_starttransfer}
          ----------
          time_total:  %{time_total}\n' -o /dev/null -s
        '';
        k = "kubectl";
        ky = "kubectl -o yaml";
        lg = "lazygit";
      };
      initExtra = ''
        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'
        . ${pkgs.complete-alias}/bin/complete_alias
        complete -F _complete_alias ky
        complete -F _complete_alias k
        complete -F _complete_alias apl
      '';
      bashrcExtra = ''
        # base64 decode helper
        b64d() {
          local secret="$1"
          echo -n "$${secret}" | base64 -d
        }
        # git clone helper
        gitclone(){ pushd ~/data/git; git clone "$@" "$(echo "$@" | sed -E 's#^.*([:/])([^/]+/[^/]+)$#\2#' | sed -E 's#\.git$##')"; popd;}
        # set google project
        function setgp() {
          export CLOUDSDK_CORE_PROJECT=$1
        }
        function setgp() {
          export CLOUDSDK_CORE_PROJECT=$1
        }
        # set aws project
        function setp() {
          export AWS_PROFILE=$1
        }
        function unsetp() {
          unset AWS_PROFILE
        }
      '';
    };

    fd.enable = true; # used in fzf

    fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "fd . $HOME";
      fileWidgetCommand = "$FZF_DEFAULT_COMMAND";
      changeDirWidgetCommand = "fd -t d . $HOME";
    };

    powerline-go = {
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
  };
}
