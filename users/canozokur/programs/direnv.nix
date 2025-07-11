{ ... }:
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    silent = true;
    # following stdlib code taken from:
    # https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories
    stdlib = ''
      : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          local hash path
          echo "''${direnv_layout_dirs[$PWD]:=$(
              hash="$(sha1sum - <<< "$PWD" | head -c40)"
              path="''${PWD//[^a-zA-Z0-9]/-}"
              echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
          )}"
      }
    '';
    nix-direnv.enable = true;
  };
}
