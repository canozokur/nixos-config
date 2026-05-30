{ lib }:
{
  getHostsWith =
    hosts: path:
    let
      # Ensure path is a list (e.g. "externalIP" -> ["externalIP"])
      keyPath = if builtins.isList path then path else [ path ];
    in
    lib.filterAttrs (
      name: host:
      let
        # Safely try to get config._meta.<path>
        # We look inside the 'host' object at .config._meta
        val = lib.attrByPath (
          [
            "config"
            "_meta"
          ]
          ++ keyPath
        ) null host;
      in
      # The Validity Checks
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
