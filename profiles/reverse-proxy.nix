{ helpers, inputs, lib, ... }:
let
  externalIP = "192.168.1.254";
  internalIP = "192.168.1.253";
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

  _meta = {
    dnsConfigurations = 
      (builtins.map (d: { ip = externalIP; domain = d; }) externalVhosts)
      ++
      (builtins.map (d: { ip = internalIP; domain = d; }) internalVhosts);

    networks.wiredAddresses = [
      externalIP
      internalIP
    ];
  };
}
