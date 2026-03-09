{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Enable iommu
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "kvmfr.static_size_mb=128" # set aside 128Mb memory for copying buffers (needs to be 2^x)
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  boot.initrd.kernelModules = [ "kvmfr" ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.udev.packages = lib.singleton (
    pkgs.writeTextFile {
      name = "kvmfr";
      text = ''
        SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-kvmfr.rules";
    }
  );

  virtualisation.libvirtd.qemu = {
    verbatimConfig = ''
      namespaces = []
      cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
        "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
        "/dev/kvmfr0"
      ]
    '';
  };

  environment.systemPackages = with pkgs; [
    looking-glass-client
  ];
}
