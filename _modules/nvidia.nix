{ config, pkgs, ... }: {

  services.xserver = {
    videoDrivers = [ "modesetting" "nvidia" ];

    #   config = ''
    #     Section "Device"
    #         Identifier  "Intel Graphics"
    #         Driver      "intel"
    #         #Option      "AccelMethod"  "sna" # default
    #         #Option      "AccelMethod"  "uxa" # fallback
    #         Option      "TearFree"        "true"
    #         Option      "SwapbuffersWait" "true"
    #         BusID       "PCI:0:2:0"
    #         #Option      "DRI" "2"             # DRI3 is now default
    #     EndSection

    #     Section "Device"
    #         Identifier "nvidia"
    #         Driver "nvidia"
    #         BusID "PCI:1:0:0"
    #         Option "AllowEmptyInitialConfiguration"
    #     EndSection
    #   '';
    #   screenSection = ''
    #     Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    #     Option         "AllowIndirectGLXProtocol" "off"
    #     Option         "TripleBuffer" "on"
    #   '';
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime ];
    };

  };
  #hardware.nvidia.forceFullCompositionPipeline = true;

  # Cuda
  # services.xmr-stak.cudaSupport = true; #Not supported after 23.11 anymore!
  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.modesetting.enable = true;
  #Switch GPU
  services.switcherooControl.enable = true;

}
