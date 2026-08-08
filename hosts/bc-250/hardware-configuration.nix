{ lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "amdgpu" "rtw89_8851bu" ]; # "rtw89_usb" "rtw89_8851b" "rtw89_core"
    };
    # nct6687 is a hardware-monitor module.
    kernelModules = [ "nct6687" ];
    kernelParams = [
      "quiet"
      "amd_iommu=off"
      "mitigations=off"
      "amd_pstate=disable"
      "processor.ignore_ppc=1"
      "ttm.pages_limit=3959290"
      "ttm.page_pool_size=3959290"
      "usbcore.autosuspend=-1"
    ];

    # Tuned for zram-only swap: no readahead on swap-in, prefer compressing
    # idle anon pages over dropping page cache, smooth kswapd instead of bursts.
    kernel.sysctl = {
      "vm.page-cluster" = 0;
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/fc78be52-e65c-48ea-b380-27f2e2a16141";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:3" "ssd" "space_cache=v2" "noatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7336-BC97";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  # 16GB GDDR6 is shared with the GPU; compressed swap beats an OOM kill mid-game.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    enableRedistributableFirmware = true; # hardware.firmware = [ pkgs.linux-firmware ];
    cpu.amd.updateMicrocode = true;
    amdgpu.initrd.enable = true;
    usb-modeswitch.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };
}
