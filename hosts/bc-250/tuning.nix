{ config, pkgs, ... }:

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

  swapDevices = [ ];
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  environment.etc."cyan-skillfish-governor-smu/config.toml".source =
    (pkgs.formats.toml { }).generate "cyan-skillfish-governor-smu.toml" {
      timing.burst-samples = 48;
      frequency-thresholds.adjust = 100;
      load-target.lower = 0.7;
      temperature = {
        throttling = 84;
        throttling_recovery = 70;
      };
      safe-points = [
        { frequency = 350; voltage = 700; }
        { frequency = 2000; voltage = 1000; }
        { frequency = 2050; voltage = 1000; }
      ];
      dbus.enabled = true;
    };

  services.dbus.packages = [ pkgs.cyan-skillfish-governor-smu ];

  systemd.services.cyan-skillfish-governor-smu = {
    description = "Cyan Skillfish SMU GPU governor";
    path = [ pkgs.util-linux ];
    wantedBy = [ "multi-user.target" ];
    after = [ "dbus.service" ];
    requires = [ "dbus.service" ];
    restartTriggers = [ config.environment.etc."cyan-skillfish-governor-smu/config.toml".source ];
    serviceConfig = {
      ExecStart = "${pkgs.cyan-skillfish-governor-smu}/bin/cyan-skillfish-governor-smu /etc/cyan-skillfish-governor-smu/config.toml";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
