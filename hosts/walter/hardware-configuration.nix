{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/06ca0142-42bb-4b9a-bb6d-560a7753adfa";
      fsType = "btrfs";
      options = [ "compress=zstd:3" "noatime" "discard=async" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/06ca0142-42bb-4b9a-bb6d-560a7753adfa";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd:3" "noatime" "discard=async" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/06ca0142-42bb-4b9a-bb6d-560a7753adfa";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd:3" "noatime" "discard=async" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E88D-FB1E";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
