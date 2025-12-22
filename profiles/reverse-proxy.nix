{ helpers, inputs, lib, config, ... }:
let
  externalIP = config._meta.networks.externalIP;
  allVhosts = helpers.getHostsWith inputs.self.nixosConfigurations "externalVhosts";
  listVhosts = lib.mapAttrsToList (_: host: host.config._meta.externalVhosts) allVhosts;
  externalVhosts = lib.flatten (lib.map (k: lib.attrNames k) listVhosts);
in
{
  imports = [
    ./capabilities/nginx.nix
    ./capabilities/consul.nix
  ];

  _meta.dnsConfigurations = builtins.map (d: {
    ip = externalIP;
    domain = d;
  }) externalVhosts;
}
