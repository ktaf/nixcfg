{ pkgs, ... }:

let
  bc250PstateTable = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/bc250-collective/bc250-acpi-fix/1594d72f11d674bd7e46f4e51eee4216155e52fb/SSDT-PST.aml";
    hash = "sha256-o3D86dlogCyaLmSzqogNiPLoHnpLlvKOrPFLBkou4zw=";
  };
  bc250PstateOverride = pkgs.runCommand "bc250-pstate-acpi-override.cpio"
    {
      nativeBuildInputs = [ pkgs.cpio ];
    } ''
    mkdir -p kernel/firmware/acpi
    cp ${bc250PstateTable} kernel/firmware/acpi/SSDT-PST.aml
    find kernel -exec touch -h -d @1 {} +
    find kernel -print0 | sort -z | cpio --null --reproducible -o -H newc > "$out"
  '';
in

{
  boot = {
    initrd.prepend = [ "${bc250PstateOverride}" ];
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
    kernel.sysctl = {
      "vm.page-cluster" = 0;
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_lavd";
    extraArgs = [ "--autopilot" "--pinned-slice-us" "500" ];
  };

  swapDevices = [ ];
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.cyan-skillfish-governor = {
    enable = true;
    settings = {
      timing = {
        intervals = {
          sample = 500;
          adjust = 200000;
        };
        ramp-rates.burst = 50;
        burst-samples = 60;
      };
      frequency-thresholds.adjust = 10;
      load-target = {
        upper = 0.80;
        lower = 0.65;
      };
      safe-points = [
        { frequency = 500; voltage = 700; }
        { frequency = 1175; voltage = 700; }
        { frequency = 1400; voltage = 750; }
        { frequency = 1600; voltage = 800; }
        { frequency = 1700; voltage = 850; }
        { frequency = 1850; voltage = 900; }
        { frequency = 2000; voltage = 950; }
        { frequency = 2050; voltage = 975; }
        { frequency = 2100; voltage = 1000; }
        { frequency = 2125; voltage = 1015; }
        { frequency = 2150; voltage = 1030; }
        { frequency = 2200; voltage = 1050; }
        { frequency = 2230; voltage = 1085; }
        { frequency = 2300; voltage = 1110; }
        { frequency = 2350; voltage = 1130; }
      ];
    };
  };
}
