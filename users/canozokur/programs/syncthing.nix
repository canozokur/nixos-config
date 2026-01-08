{ ... }:
{
  services.syncthing = {
    enable = true;
    # since this is shared with non-nixos users I cba to declare everything here
    # maybe someday..
    overrideFolders = false;
    overrideDevices = false;
    settings.defaults.folder = {
      path = "~/sync";
    };
  };
}
