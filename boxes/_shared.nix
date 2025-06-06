{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.optimise = {
    automatic = true;
    dates = ["03:45"];
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout=30
    '';
  };

  environment.systemPackages = with pkgs; [
    wget
    git
  ];
}
