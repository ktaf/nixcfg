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
      device = "/dev/disk/by-uuid/20b4bfe1-4a8a-438f-945a-dec499d2b1d6";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/20b4bfe1-4a8a-438f-945a-dec499d2b1d6";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/20b4bfe1-4a8a-438f-945a-dec499d2b1d6";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/0834-95F5";
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
