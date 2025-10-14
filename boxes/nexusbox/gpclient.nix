{ pkgs, inputs, ... }:
let
  gpclient-connect = pkgs.writeScriptBin "gpclient-connect" ''
    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
    fi
    ${pkgs.gpclient}/bin/gpclient --fix-openssl connect ${inputs.nix-secrets.network.office-vpn-address}
  '';
in
{
  environment.systemPackages = with pkgs; [
    gpauth
    gpclient
    gpclient-connect
  ];

}
