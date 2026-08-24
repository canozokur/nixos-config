{ pkgsFast, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgsFast.claude-code;
  };
}
