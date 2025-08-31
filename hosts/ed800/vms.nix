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
      "vfio-pci.ids=10de:1c03,10de:10f1" # GTX 1060 + HDA
    ];
    # Load VFIO in the initrd so nothing grabs the GPU first
    initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
    kernelModules = [ ];
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
  ];

  services.qemuGuest.enable = true;

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}
