{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.box.networking.tailnet;
in
{
  options.box.networking.tailnet = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "fleet";
      description = ''
        Headscale user this machine registers under. Selects the sops
        preauth key `tailscale/authkey-<user>`. The `fleet` user owns all
        NixOS machines; per-person users are for personally-owned devices.
        Set to "" to disable the module on this host.
      '';
    };
    advertiseExitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Offer this machine as an exit node (guild, tr).";
    };
    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Accept subnet routes advertised by the routers. An accepted route
        shadows the directly-connected route for its prefix (table 52 wins
        over main), so home-LAN-stationary boxes should disable this: their
        LAN access stays direct and tailnet-independent. Roaming boxes and
        servers that must reach the home LAN keep it enabled.
      '';
    };
    controlServer = lib.mkOption {
      type = lib.types.str;
      default = "https://hs.pco.pink";
      description = ''
        Headscale control plane URL, passed to tailscale as --login-server.
        Without it tailscaled registers against Tailscale's SaaS and any
        headscale-issued preauth key is rejected.
      '';
    };
    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Subnet routes to advertise, e.g. the home LAN on rpi01/rpi02.";
    };
    gui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install trayscale and let `operator` control tailscaled without root.";
    };
    operator = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Linux user allowed to control tailscaled (required when gui = true).";
    };
  };

  config = lib.mkIf (cfg.user != "") {
    assertions = [
      {
        assertion = cfg.gui -> cfg.operator != "";
        message = "box.networking.tailnet.gui requires box.networking.tailnet.operator.";
      }
      {
        assertion = config.services.resolved.enable;
        message = "tailscale (MagicDNS) requires services.resolved.enable — the resolver is configured fleet-wide in services/core/common.nix.";
      }
    ];

    sops.secrets."tailscale/authkey-${cfg.user}" = { };

    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = config.sops.secrets."tailscale/authkey-${cfg.user}".path;

      # "server" enables IP forwarding (subnet router / exit node duty);
      # "client"/"both" relax the firewall reverse-path check. Exit nodes get
      # "both": they forward AND accept the home subnet routes.
      useRoutingFeatures =
        if cfg.advertiseRoutes != [ ] then
          "server"
        else if cfg.advertiseExitNode then
          "both"
        else
          "client";

      extraUpFlags =
        [ "--login-server=${cfg.controlServer}" ]
        # Consume the subnet routers' routes except on the routers themselves
        # (accepting a route for an already-connected LAN is noise) and on
        # boxes that opt out to keep LAN access direct.
        ++ lib.optionals (cfg.advertiseRoutes == [ ] && cfg.acceptRoutes) [
          "--accept-routes"
        ]
        ++ lib.optionals (cfg.advertiseRoutes != [ ]) [
          "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}"
        ]
        ++ lib.optionals cfg.advertiseExitNode [ "--advertise-exit-node" ]
        ++ lib.optionals (cfg.operator != "") [ "--operator=${cfg.operator}" ];

      # Keep crash/log telemetry off tailscale.com — the fleet is self-hosted.
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };

    environment.systemPackages = lib.optionals cfg.gui [ pkgs.trayscale ];
  };
}