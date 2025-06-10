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
    greetd.greetd
    greetd.tuigreet
  ];

  services.greetd = {
    enable = true;
    restart = true;
    vt = 1;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
      };
    };
  };

  security.polkit.enable = true; # required for sway
  security.pam.services.swaylock = {}; # required for swaylock
}
