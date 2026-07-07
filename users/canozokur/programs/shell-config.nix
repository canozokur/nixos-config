{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
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
        ll = "ls -lav --ignore=.."; # show long listing of all except ".."
        l = "ls -lav --ignore=.?*"; # show long listing but no hidden dotfiles except "."
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
      };
      initExtra = ''
        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'
        . ${pkgs.complete-alias}/bin/complete_alias
        complete -F _complete_alias ky
        complete -F _complete_alias k
        complete -F _complete_alias apl
        ${lib.optionalString (config.sops.secrets ? "claude-code/oauth-token") ''
          export CLAUDE_CODE_OAUTH_TOKEN="$(cat ${config.sops.secrets."claude-code/oauth-token".path})"
        ''}
      '';
      bashrcExtra = ''
            # base64 decode helper
            b64d() {
              local secret="$1"
              echo -n "''${secret}" | base64 -d
            }
            # git clone helper
            function gitclone() {
              local REPOID="$(echo "$@" | sed -E 's#^.*([:/])([^/]+/[^/]+)$#\2#' | sed -E 's#\.git$##')"
              mkdir -p ~/data/git
              pushd ~/data/git
              git clone "$@" "$REPOID"
              popd
            }
            # git worktree helper
            werk() {
              local cmd="$1"
              if [[ -z "$cmd" ]]; then
                git worktree
                return
              fi
              shift
              if [[ "$cmd" == "add" ]]; then
                local root="" branch=""
                while [[ $# -gt 0 ]]; do
                  case "$1" in
                    --root)
                      root="$2"
                      shift 2
                      ;;
                    *)
                      branch="$1"
                      shift
                      ;;
                  esac
                done
                if [[ -z "$branch" ]]; then
                  echo "Error: You must provide a branch name."
                  echo "Usage: werk add [--root owner/repo] <branch>"
                  return 1
                fi
                if [[ -z "$root" ]]; then
                  local remote_url
                  remote_url=$(git remote get-url origin 2>/dev/null) || {
                    echo "Error: No 'origin' remote found. Use --root owner/repo to specify the path."
                    return 1
                  }
                  root=$(echo "$remote_url" | sed -E 's#^.*([:/])([^/]+/[^/]+)$#\2#' | sed -E 's#\.git$##')
                fi
                local worktree_path="$HOME/data/worktrees/$root/$branch"
                mkdir -p "$(dirname "$worktree_path")"
                if git show-ref --verify --quiet "refs/heads/$branch"; then
                  git worktree add "$worktree_path" "$branch"
                else
                  git worktree add -b "$branch" "$worktree_path"
                fi && pushd "$worktree_path"
              else
                git worktree "$cmd" "$@"
              fi
            }
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

            export VAULT_ADDR=${inputs.nix-secrets.bash_env.vault_addr}
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
  };
}
