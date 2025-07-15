{ config, pkgs, ... }:

{
  # Kernel options for IOMMU and NVIDIA
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "nvidia.NVreg_UsePageAttributeTable=1"
    "nvidia.NVreg_EnablePCIeGen3=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # NVIDIA drivers with Open Kernel Module (recommended for passthrough stability)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # Enables runtime power management
    powerManagement.finegrained = true;
    nvidiaSettings = false;
    open = true; # Use open kernel module
    package = config.boot.kernelPackages.nvidiaPackages.stable;

  };

  environment.variables = {
    # Optional: disable GUI output on GPU
    "NVDISABLEDISPLAY" = "1";
  };
}
