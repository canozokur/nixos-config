{ ... }:
{
  imports = [
    ./base/desktop.nix
    ./base/consul.nix
    ./base/gaming.nix
    ./base/remote-builder.nix
    ./base/node-exporter.nix
  ];
}
