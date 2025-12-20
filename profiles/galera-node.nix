{ ... }:
{
  imports = [
    ./capabilities/mysql.nix
    ./capabilities/consul.nix
    ./capabilities/iscsi-initiator.nix
  ];
}
