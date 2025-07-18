{ pkgs, user, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };
  # Kernel options for IOMMU and NVIDIA
  boot = {
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "nvidia.NVreg_UsePageAttributeTable=1"
      "nvidia.NVreg_EnablePCIeGen3=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    extraModprobeConfig = ''
      options vfio-pci ids=10de:1c82,10de:0fb9
    '';

    # blacklistedKernelModules = [
    #   "nouveau"
    #   "nvidiafb"
    #   "rivafb"
    #   "nvidia_drm"
    #   "nvidia"
    # ];
  };
  users.users.${user}.extraGroups = [ "libvirtd" "qemu-libvirtd" "kvm" ];

  environment.systemPackages = with pkgs; [
    qemu_kvm
    swtpm
    OVMF
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    qemu_kvm
    win-virtio
    win-spice
    looking-glass-client
  ];
}
