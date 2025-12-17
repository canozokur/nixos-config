{ ... }:
{
  imports = [
    ./capabilities/desktop.nix
    ./capabilities/consul.nix
    ./capabilities/gaming.nix
    ./capabilities/remote-builder.nix
    ./capabilities/node-exporter.nix
  ];
}
