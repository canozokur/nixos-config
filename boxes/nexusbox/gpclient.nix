{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gpauth
    gpclient
  ];
}
