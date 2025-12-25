{ helpers, inputs, lib, ... }:
let
  externalIP = "192.168.1.254";
  internalIP = "192.168.1.253";
  vhostConfigurations = helpers.getHostsWith inputs.self.nixosConfigurations ["nginx" "vhosts"];
in
{
  imports = [
    ./capabilities/nginx.nix
    ./capabilities/consul.nix
  ];

  _meta = {
    dnsConfigurations = lib.flatten (
      lib.mapAttrsToList (name: node:
        let
          vhosts = node.config._meta.nginx.vhosts;
        in
        lib.mapAttrsToList (d: c:
          let
            listenList = c.listen or [];
            customIps = builtins.filter (x: x != null)
              (builtins.map (e: e.addr or null) listenList);
            finalIps = if customIps != [] then customIps else [ internalIP ];
          in
          builtins.map (ip:
            { domain = d; ip = ip; }
          ) finalIps
        ) vhosts
      ) vhostConfigurations
    );

    networks.wiredAddresses = [
      externalIP
      internalIP
    ];
  };
}
