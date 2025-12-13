{ lib }:
{
  getHostsWith = hosts: path:
    let
      # Ensure path is a list (e.g. "externalIP" -> ["externalIP"])
      keyPath = if builtins.isList path then path else [ path ];
    in
    lib.filterAttrs (name: host:
      let
        # Safely try to get config._meta.<path>
        # We look inside the 'host' object at .config._meta
        val = lib.attrByPath ([ "config" "_meta" ] ++ keyPath) null host;
      in
        # The Validity Checks
        val != null && val != "" && val != [] && val != false
    ) hosts;
}
