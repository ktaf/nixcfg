{ config, ... }:

{
  # NVIDIA drivers for GPU passthrough
  services.xserver = {
    enable = false;
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = false;
    open = true; # Use open kernel module for headless and PCI-passthrough
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Kernel modules for NVIDIA
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Disable GUI output on GPU for passthrough
  environment.variables.NVDISABLEDISPLAY = "1";
}
