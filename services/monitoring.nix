{
  config,
  lib,
  helpers,
  inputs,
  mkReverseProxyService,
  ...
}:
let
  # Feature flag: grafana's SSO wiring appears only when some host in the
  # fleet runs Authelia (helpers.getAuthelia returns null otherwise).
  authelia = helpers.getAuthelia inputs.self.nixosConfigurations;
  autheliaDomain = "auth.pco.pink";
in
{
  imports = [
    ./base/consul.nix
    ./base/iscsi-initiator.nix
  ];

  sops.secrets."grafana/secret-key" = {
    owner = "grafana";
    group = "grafana";
  };

  sops.secrets."grafana/oidc-client-secret" = lib.mkIf (authelia != null) {
    owner = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;
    openFirewall = true;
    settings = {
      server.http_addr = "0.0.0.0";
      server.http_port = 2324;
      # Correct public redirect URI (OAuth redirect_uri derives from this).
      server.root_url = "https://grafana.pco.pink";
      security.secret_key = "$__file{${config.sops.secrets."grafana/secret-key".path}}";
    } // lib.optionalAttrs (authelia != null) {
      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        icon = "signin";
        client_id = "grafana";
        client_secret = "$__file{${config.sops.secrets."grafana/oidc-client-secret".path}}";
        scopes = "openid profile email groups";
        empty_scopes = false;
        auth_url = "https://${autheliaDomain}/api/oidc/authorization";
        token_url = "https://${autheliaDomain}/api/oidc/token";
        api_url = "https://${autheliaDomain}/api/oidc/userinfo";
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        name_attribute_path = "name";
        use_pkce = true;
        role_attribute_path = "contains(groups[], 'admins') && 'Admin' || 'Viewer'";
        allow_sign_up = false;
      };
      # authelia subs are per-user UUIDs, so ids never match existing local
      # accounts; allow matching by the provider's email claim instead.
      auth.oauth_allow_insecure_email_lookup = true;
      # disable default login when authelia is enabled
      auth.disable_login = true;
      auth.disable_login_form = true;
    };
    provision = {
      datasources.settings = {
        prune = true;
        datasources = [
          {
            name = "local prom";
            type = "prometheus";
            url = "http://localhost:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
  };

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "2y";
    scrapeConfigs = [
      {
        job_name = "self";
        static_configs = [
          {
            targets = [ "localhost:9090" ];
          }
        ];
      }
      {
        job_name = "headscale";
        # Resolved via MagicDNS on this node; the scrape rides the overlay.
        static_configs = [
          {
            targets = [ "guild.ts.pco.pink:19090" ];
            labels = { instance = "guild"; };
          }
        ];
      }
      {
        job_name = "consul";
        consul_sd_configs = [
          {
            server = "consul.pco.pink:8500";
          }
        ];
        # relabel configuration for consul server metrics
        # documentation: https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
        # keep: without this the job scrapes EVERY registered service at
        # /metrics (couchdb answered 401, mysql got probed as well)
        relabel_configs = [
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "consul";
            action = "keep";
          }
          {
            source_labels = [
              "__address__"
              "__meta_consul_service"
            ];
            separator = ":";
            regex = "(.*):(8300):(consul)";
            target_label = "__address__";
            replacement = "\${1}:8500";
          }
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "consul";
            target_label = "__param_format";
            replacement = "prometheus";
          }
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "consul";
            target_label = "__metrics_path__";
            replacement = "/v1/agent/metrics";
          }
        ];
      }
      {
        job_name = "node-exporter";
        consul_sd_configs = [
          {
            server = "127.0.0.1:8500";
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "node-exporter";
            action = "keep";
          }
          {
            source_labels = [ "__meta_consul_node" ];
            target_label = "instance";
          }
        ];
      }
      {
        job_name = "couchdb";
        # couchdb's dedicated metrics listener, registered in consul by
        # services.obsidian-sync (tailnet address). The path embeds the erlang
        # node name (nixpkgs vm.args default, single node).
        consul_sd_configs = [
          {
            server = "127.0.0.1:8500";
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "obsidian-sync-metrics";
            action = "keep";
          }
          {
            source_labels = [ "__meta_consul_node" ];
            target_label = "instance";
          }
        ];
        metrics_path = "/_node/couchdb@127.0.0.1/_prometheus";
      }
      {
        job_name = "authelia";
        consul_sd_configs = [
          {
            server = "127.0.0.1:8500";
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__meta_consul_service" ];
            regex = "authelia-metrics";
            action = "keep";
          }
          {
            source_labels = [ "__meta_consul_node" ];
            target_label = "instance";
          }
        ];
      }
    ];
  };

  services.reverseProxy.contribs = mkReverseProxyService {
    inherit config lib;
    name = "grafana";
    subdomain = "grafana";
    port = 2324;
    exposure = "public";
    # Consumed by services/authelia.nix when it collects fleet clients.
    oidc = {
      client_id = "grafana";
      client_name = "Grafana";
      # sops key holding the pbkdf2 digest of the plaintext in
      # `grafana/oidc-client-secret`; authelia expands it at startup.
      client_secret_file = "authelia/clients/grafana";
      authorization_policy = "one_factor";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [ "https://grafana.pco.pink/login/generic_oauth" ];
      scopes = [
        "openid"
        "profile"
        "groups"
        "email"
      ];
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      access_token_signed_response_alg = "none";
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    };
  };

  systemd.services.prometheus.unitConfig = {
    RequiresMountsFor = "/mnt/prometheus-data";
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/${config.services.prometheus.stateDir}/data - - - - /mnt/prometheus-data"
  ];
}
