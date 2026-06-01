{ lib }:
{
  # Returns the subset of `hosts` whose `config._meta.<path>` is non-default
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
            "_meta"
          ]
          ++ path
        ) null host;
      in
      val != null && val != "" && val != [ ] && val != false && val != { }
    ) hosts;

  # Returns the unique host with _meta.services.reverseProxy.enable = true.
  # Throws if zero or more than one host matches — fail fast on misconfiguration.
  getProxy =
    hosts:
    let
      matches = lib.filterAttrs (
        _: h:
        lib.attrByPath [
          "config"
          "_meta"
          "services"
          "reverseProxy"
          "enable"
        ] false h
      ) hosts;
      names = lib.attrNames matches;
      count = lib.length names;
    in
    if count == 0 then
      throw "getProxy: no host has _meta.services.reverseProxy.enable = true"
    else if count > 1 then
      throw "getProxy: multiple reverse-proxy hosts: ${lib.concatStringsSep ", " names}"
    else
      let
        name = lib.head names;
        meta = matches.${name}.config._meta.services.reverseProxy;
      in
      {
        inherit (meta) externalIP internalIP;
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
