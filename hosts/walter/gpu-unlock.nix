{ config, ... }:

let
  gpuUnlock = config.boot.kernelPackages.callPackage ../../pkgs/gpu-unlock.nix { };
  driverLoaders = [
    "systemd-udevd.service"
    "systemd-udev-trigger.service"
    "systemd-modules-load.service"
  ];
in
{
  boot.extraModulePackages = [ gpuUnlock ];
  hardware.firmware = [ gpuUnlock.firmware ];

  boot.kernelParams = [ "gpu_unlock.targets=0000:01:00.0" ];
  boot.initrd.availableKernelModules = [ "gpu_unlock" ];

  boot.initrd.systemd.services.gpu-unlock = {
    description = "Unlock Walter's RTX 3090 before loading GPU drivers";
    wantedBy = driverLoaders;
    before = driverLoaders;
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/bin/modprobe gpu_unlock";
    };
  };
}
