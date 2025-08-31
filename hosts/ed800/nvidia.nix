{ ... }:

{
  services.xserver.enable = false;

  # Ensure nothing grabs the card on host
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
    "nvidia_uvm"
  ];
}
