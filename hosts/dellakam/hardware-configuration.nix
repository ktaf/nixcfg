{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [
    "intel_idle.max_cstate=10"
    "processor.max_cstate=10"
    "rcu_nocbs=0-11"
    "nohz=on"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0948688b-34bf-44a3-9394-97a97b798dd6";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/6547-47C3";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/DATA";
    fsType = "btrfs";
    options = [ "subvol=@data" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" "user" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
