{ inputs, lib, ... }:
{
  imports = [
    ./base/remote-builder-client.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  # see: https://discourse.nixos.org/t/cannot-build-raspberry-pi-sdimage-module-dw-hdmi-not-found/71804
  boot.initrd.allowMissingModules = true;

  # The sd-image installer profile enables zfs support (with a default hostId)
  # for every image; the rpis boot ext4, so drop it. Left on, the zfs module
  # also warns about boot.zfs.forceImportRoot using its default.
  boot.supportedFilesystems.zfs = lib.mkForce false;

  box.build.remoteBuilders = [
    {
      host = "guild";
      systems = [ "aarch64-linux" ];
    }
  ];
}
