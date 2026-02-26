{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
  };

  environment.systemPackages = with pkgs; [
    quickemu
    lm_sensors
  ];

  programs.coolercontrol.enable = true;
}
