{ config, ... }:
{
  sops.secrets."spotify/client-id" = {};

  programs.spotify-player = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      client_id_command = {
        command = "cat";
        args = [ config.sops.secrets."spotify/client-id".path ];
      };
    };
  };

  xdg.desktopEntries.spotify-player = {
    name = "spotify-player";
    exec = "wezterm -e spotify_player";
    terminal = false;
    type = "Application";
    categories = [ "Audio" ];
  };
}
