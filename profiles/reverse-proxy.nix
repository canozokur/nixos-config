{ helpers, inputs, lib, config, ... }:
let
  externalIP = config._meta.networks.externalIP;
  internalIP = config._meta.networks.internalIP;
  get = helpers.getHostsWith inputs.self.nixosConfigurations;
  listExtVhosts = lib.mapAttrsToList
    (_: host: host.config._meta.nginx.externalVhosts)
    (get ["nginx" "externalVhosts"]);
  listIntVhosts = lib.mapAttrsToList
    (_: host: host.config._meta.nginx.internalVhosts)
    (get ["nginx" "internalVhosts"]);
  externalVhosts = lib.flatten (lib.map (k: lib.attrNames k) listExtVhosts);
  internalVhosts = lib.flatten (lib.map (k: lib.attrNames k) listIntVhosts);
in
{
  imports = [
    ./capabilities/nginx.nix
    ./capabilities/consul.nix
  ];

  _meta.dnsConfigurations = 
    (builtins.map (d: {
      ip = externalIP;
      domain = d;
    }) externalVhosts)
    ++
    (builtins.map (d: {
      ip = internalIP;
      domain = d;
    }) internalVhosts);
}
