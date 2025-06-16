{ config, pkgs, ... }:
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
}
