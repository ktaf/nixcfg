{ pkgs, user, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  };

  # Kernel configuration for IOMMU and GPU passthrough
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
    ];
    # options vfio-pci ids=10de:1c82,10de:0fb9  #GTX 1050
    extraModprobeConfig = ''
      options vfio-pci ids=10de:1c07
    '';
  };

  # User permissions for virtualization
  users.users.${user}.extraGroups = [ "libvirtd" "qemu-libvirtd" "kvm" ];

  # Virtualization and GPU passthrough tools
  environment.systemPackages = with pkgs; [
    qemu_kvm
    swtpm
    OVMF
    virt-manager
    virt-viewer
    virtio-win
    win-spice
    looking-glass-client
  ];

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}
