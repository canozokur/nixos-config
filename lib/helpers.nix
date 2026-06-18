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

  # Returns the unique host with services.reverseProxy.host.enable = true.
  # Throws if zero or more than one host matches — fail fast on misconfiguration.
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
      ) hosts;
      names = lib.attrNames matches;
      count = lib.length names;
    in
    if count == 0 then
      throw "getProxy: no host has services.reverseProxy.host.enable = true"
    else if count > 1 then
      throw "getProxy: multiple reverse-proxy hosts: ${lib.concatStringsSep ", " names}"
    else
      let
        name = lib.head names;
        cfg = matches.${name}.config.services.reverseProxy.host;
      in
      {
        inherit (cfg) externalIP internalIP;
        hostname = name;
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
