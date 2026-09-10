{
  lib,
  pkgs,
  ...
}:
let
  domain = "derp.pco.pink";
  internalPort = 8443;
in
{
  # Standalone DERP relay behind nginx
  config = {
    systemd.services.derper = {
      description = "Tailscale DERP relay server";
      # -verify-clients talks to the local tailscaled, so only tailnet nodes
      # may relay through
      after = [
        "network.target"
        "tailscaled.service"
      ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        # -c holds the DERP node private key (auto-generated 0600 on first
        # run); StateDirectory pre-creates /var/lib/derper root-owned. All
        # other behavior is flag-driven: -a on a non-443 port serves plain
        # HTTP (nginx terminates TLS), so -http-port is disabled.
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.tailscale.derper}/bin/derper"
          "-c /var/lib/derper/derper.key"
          "-hostname ${domain}"
          "-a :${toString internalPort}"
          "-http-port -1"
          "-stun-port 3478"
          "-verify-clients"
          "-home blank"
        ];
        StateDirectory = "derper";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString internalPort}";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
          '';
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "ssladmin@pco.pink";
      defaults.reloadServices = [ "nginx" ];
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ 3478 ];
    };
  };
}
