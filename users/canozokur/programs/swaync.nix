{ pkgs, ... }:
let
  ctp-mocha = pkgs.fetchurl {
    url = "https://github.com/catppuccin/swaync/releases/download/v0.2.3/mocha.css";
    hash = "sha256-Hie/vDt15nGCy4XWERGy1tUIecROw17GOoasT97kIfc=";
  };

  # by default ctp-mocha is configured for Ubuntu fonts
  # we don't want that
  ctp-mocha-fc = builtins.replaceStrings
    [ "font-family: \"Ubuntu Nerd Font\";" ]
    [ "font-family: \"CaskaydiaCove NFM\";" ]
    (builtins.readFile ctp-mocha);
in
{
  # this is required for proper icons i.e. "no notifications" icon
  home.packages = [ pkgs.adwaita-icon-theme ];

  services.swaync = {
    enable = true;
    settings = {
      transition-time = 200;
      widgets = [
        "title"
        "dnd"
        "notifications"
        "mpris"
        "volume"
      ];
      widget-config = {
        title.button-text = " 󰎟 ";
        volume.label = "";
        mpris.blacklist = ["playerctld"];
      };
    };
    style = ctp-mocha-fc;
  };
}
