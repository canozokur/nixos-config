{
  inputs,
  helpers,
  lib,
  ...
}:
let
  # home-LAN resolver, for the split-DNS zone
  piholeHosts = helpers.getHostsWith inputs.self.nixosConfigurations [
    "services"
    "pihole"
    "dnsServer"
  ];
  piholeNameservers = lib.mapAttrsToList (
    _: h: h.config.box.networking.internalIP
  ) piholeHosts;

  websocketConfig = ''
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
  '';
in
{
  config = {
    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8080;
      settings = {
        server_url = "https://hs.pco.pink";
        # Debug/metrics listener
        metrics_listen_addr = "127.0.0.1:19090";

        dns = {
          magic_dns = true;
          base_domain = "ts.pco.pink";
          # Split DNS only: matched zones go to Pi-hole over the overlay,
          # everything else keeps the machine's own resolvers. MagicDNS names
          # still resolve via the tailnet resolver regardless.
          override_local_dns = false;
        } // lib.optionalAttrs (piholeNameservers != [ ]) {
          nameservers.split = {
            "lan" = piholeNameservers;
            "pco.pink" = piholeNameservers;
          };
        };

        derp = {
          urls = [ ];
          paths = [ ./files/derpmap-tr.yaml ];
          auto_update_enabled = false;
          server = {
            enabled = true;
            region_id = 900;
            region_code = "guild";
            region_name = "Sweden";
            # Only tailnet nodes may relay through this internet-reachable
            # endpoint, and STUN must bind externally (default is loopback)
            # for NAT-type detection to work via guild.
            verify_clients = true;
            stun_listen_addr = "0.0.0.0:3478";
          };
        };

        policy = {
          mode = "file";
          path = ./files/headscale-policy.hujson;
        };
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."hs.pco.pink" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          recommendedProxySettings = true;
          extraConfig = websocketConfig;
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "ssladmin@pco.pink";
      defaults.reloadServices = [ "nginx" ];
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [ 3478 ];
  };
}
