{ config, pkgs, user, ... }:

{
  virtualisation = {
    libvirtd.enable = true;
    libvirtd.qemu.verbatimConfig = ''
      user = "root"
      cgroup_controllers = [ "cpu" "memory" "cpuset" ]
    '';
  };

  boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" ];

  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1c82,10de:0fb9
  '';

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
    "rivafb"
    "nvidia_drm"
    "nvidia"
  ];

  users.users.${user}.extraGroups = [ "libvirtd" "qemu-libvirtd" "kvm" ];

  environment.systemPackages = with pkgs; [
    qemu_kvm
    swtpm
    OVMF
    looking-glass-client
  ];
}
