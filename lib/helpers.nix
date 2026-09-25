{ lib }:
{
  # Returns the subset of `hosts` whose `config.<path>` is non-default
  # (i.e. not null/""/[ ]/false/{ }). Use this to find hosts that
  # meaningfully contribute to a fleet-level aggregate — vhosts they want
  # proxied, peers in a galera cluster, hosts that run a DNS server, etc.
  getHostsWith =
    hosts: path:
    lib.filterAttrs (
      name: host:
      let
        val = lib.attrByPath (
          [
            "config"
          ]
          ++ path
        ) null host;
      in
      val != null && val != "" && val != [ ] && val != false && val != { }
    ) hosts;

  # Returns the unique internal-tier reverse proxy host
  # (services.reverseProxy.host.enable = true, role != "public"). Public
  # entry-point hosts enable the same module but don't provide the internal
  # listen addresses contribs default to. Throws if zero or more than one
  # internal host matches — fail fast on misconfiguration.
  getProxy =
    hosts:
    let
      matches = lib.filterAttrs (
        _: h:
        lib.attrByPath [
          "config"
          "services"
          "reverseProxy"
          "host"
          "enable"
        ] false h
        && lib.attrByPath [
          "config"
          "services"
          "reverseProxy"
          "host"
          "role"
        ] "internal" h != "public"
      ) hosts;
      names = lib.attrNames matches;
      count = lib.length names;
    in
    if count == 0 then
      throw "getProxy: no internal reverse-proxy host (services.reverseProxy.host.enable = true)"
    else if count > 1 then
      throw "getProxy: multiple internal reverse-proxy hosts: ${lib.concatStringsSep ", " names}"
    else
      let
        name = lib.head names;
        cfg = matches.${name}.config.services.reverseProxy.host;
      in
      {
        inherit (cfg) internalIP;
        hostname = name;
      };

  # Returns the unique fleet Authelia host as { hostName; tailnetIP; } or
  # null when no host configures any instance. SSO-gating modules read this
  # to decide whether to emit their OIDC/forward-auth configuration.
  getAuthelia =
    hosts:
    let
      # An instance exists wherever the instances attrset is non-empty
      # (setting any instance's enable flips it non-empty via the module).
      hasInstances =
        h:
        let
          instances = lib.attrByPath [
            "config"
            "services"
            "authelia"
            "instances"
          ] null h;
        in
        instances != null && instances != { };
      matches = lib.filterAttrs (_: hasInstances) hosts;
      names = lib.attrNames matches;
      count = lib.length names;
    in
    if count == 0 then
      null
    else if count > 1 then
      throw "getAuthelia: multiple Authelia hosts: ${lib.concatStringsSep ", " names}"
    else
      {
        hostName = lib.head names;
        tailnetIP = lib.attrByPath [
          "config"
          "box"
          "networking"
          "tailnet"
          "ip"
        ] null matches.${lib.head names};
      };

  # Converts a list [ "a" "b" ] -> { prefix1="a"; prefix2="b"; }
  listToNumberedAttrs =
    prefix: list:
    lib.listToAttrs (
      lib.imap1 (i: v: {
        name = "${prefix}${toString i}";
        value = v;
      }) list
    );
}
