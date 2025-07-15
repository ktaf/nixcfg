{ pkgs, user, ... }:

{
  virtualisation.libvirtd.enable = true;

  # Enable IOMMU passthrough support
  boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" ];

  # Bind GPU and HDMI audio controller to vfio-pci
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1c82,10de:0fb9
  '';

  # Isolate GPU from host system
  boot.blacklistedKernelModules = [ "nouveau" "nvidiafb" "rivafb" "nvidia_drm" "nvidia" ];

  # Enable QEMU/KVM with support for UEFI and TPM
  virtualisation.qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    hostCPUOnly = false;
    ovmf.enable = true;
    swtpm.enable = true;
  };

  users.users.${user}.extraGroups = [ "libvirtd" "qemu-libvirtd" "kvm" ]; # Replace with your actual username
}
