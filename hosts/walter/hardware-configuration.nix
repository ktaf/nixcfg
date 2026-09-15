{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/20b4bfe1-4a8a-438f-945a-dec499d2b1d6";
      fsType = "btrfs";
      options = [ "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
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
      options = [ "subvol=nix" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
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

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/1a858864-f759-420b-9482-b12e32bdb101";
    fsType = "btrfs";
    options = [ "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
  };

  fileSystems."/fast" = {
    device = "/dev/disk/by-uuid/d2c1fe71-d4dd-4008-8d63-af877a341daf";
    fsType = "btrfs";
    options = [ "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
