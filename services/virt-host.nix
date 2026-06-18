{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Define your variables here so you only ever have to change them in one place
  vmName = "win11";
  gpuVideo = config._meta.gpuPassthrough.video;
  gpuAudio = config._meta.gpuPassthrough.audio;
in
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

  virtualisation.libvirtd.hooks.qemu = {
    "dynamic-vfio" = pkgs.writeShellScript "dynamic-vfio" ''
      GUEST_NAME="$1"
      OPERATION="$2"

      # Inject the Nix variables into Bash variables
      VM_NAME="${vmName}"
      GPU_VIDEO="${gpuVideo}"
      GPU_AUDIO="${gpuAudio}"

      if [ "$GUEST_NAME" == "$VM_NAME" ]; then

        if [ "$OPERATION" == "prepare" ]; then
          # Forcefully kick audio services off the GPU's audio chip
          fuser -k "/dev/snd/by-path/pci-$GPU_AUDIO"* || true
          sleep 1

          # Unbind from amdgpu and bind to vfio-pci
          echo "$GPU_VIDEO" > "/sys/bus/pci/devices/$GPU_VIDEO/driver/unbind" || true
          echo "$GPU_AUDIO" > "/sys/bus/pci/devices/$GPU_AUDIO/driver/unbind" || true

          echo "vfio-pci" > "/sys/bus/pci/devices/$GPU_VIDEO/driver_override"
          echo "vfio-pci" > "/sys/bus/pci/devices/$GPU_AUDIO/driver_override"

          echo "$GPU_VIDEO" > "/sys/bus/pci/drivers/vfio-pci/bind"
          echo "$GPU_AUDIO" > "/sys/bus/pci/drivers/vfio-pci/bind"
        fi

        if [ "$OPERATION" == "release" ]; then
          # Unbind from vfio-pci and bind back to amdgpu
          echo "$GPU_VIDEO" > "/sys/bus/pci/devices/$GPU_VIDEO/driver/unbind" || true
          echo "$GPU_AUDIO" > "/sys/bus/pci/devices/$GPU_AUDIO/driver/unbind" || true

          # Clear the virtualization driver override
          echo "" > "/sys/bus/pci/devices/$GPU_VIDEO/driver_override"
          echo "" > "/sys/bus/pci/devices/$GPU_AUDIO/driver_override"

          # Completely remove the GPU from the Linux PCI bus
          echo 1 > "/sys/bus/pci/devices/$GPU_VIDEO/remove"
          echo 1 > "/sys/bus/pci/devices/$GPU_AUDIO/remove"
          sleep 2

          echo 1 > /sys/bus/pci/rescan
          udevadm settle
          sleep 3

          # Restart LACT for good measure
          systemctl restart lactd
        fi
      fi
    '';
  };
}
