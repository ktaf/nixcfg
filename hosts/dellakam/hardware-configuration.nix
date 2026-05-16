{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "uas" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [
    "intel_idle.max_cstate=10"
    "processor.max_cstate=10"
    "rcu_nocbs=0-11"
    "nohz=on"
    "iomem=relaxed"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/6650efb0-96ca-4693-87a3-568df75747c2";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/6650efb0-96ca-4693-87a3-568df75747c2";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/1DC0-7818";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/b9c7d002-ff5a-40be-a406-2ac046d9af8a";
    fsType = "btrfs";
    options = [ "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
