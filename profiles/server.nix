{ ... }:
{
  imports = [
    ./capabilities/consul.nix
    ./capabilities/node-exporter.nix
    ./capabilities/iscsi-initiator.nix
  ];
}
