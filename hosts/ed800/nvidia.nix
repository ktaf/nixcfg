{ config, ... }:

{

  # NVIDIA drivers with Open Kernel Module (recommended for passthrough stability)
  services = {
    xserver = {
      enable = false;
      videoDrivers = [ "nvidia" ];
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # Enables runtime power management
    powerManagement.finegrained = false;
    nvidiaSettings = false;
    open = true; # Use open kernel module
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # hardware.nvidia = {
  #   modesetting.enable = false;
  #   powerManagement.enable = true;
  #   powerManagement.finegrained = true;
  #   nvidiaSettings = false;
  #   open = false;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

  environment.variables = {
    # Optional: disable GUI output on GPU
    "NVDISABLEDISPLAY" = "1";
  };
}
