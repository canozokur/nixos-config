{
  fileSystems."/mnt/sonarr-data" = {
    device = "/dev/disk/by-uuid/9b9cea9d-b9a0-4115-ab64-40b53859f800";
    fsType = "xfs";
    options = [
      "nofail"
      "_netdev"
      "auto"
      "exec"
      "defaults"
    ];
  };
}
