{ config, pkgs, ... }:

let
  bc250AcpiFix = pkgs.fetchFromGitHub {
    owner = "ktaf";
    repo = "bc250-acpi-fix";
    rev = "e55543c822811d2e6daa3e8ee44e7c5193886fbd";
    hash = "sha256-b9g/hF+otnbbI94wOJUGtyi3G1TPr0MiTcEBWRGjFs8=";
  };
  # P-state table and corrected firmware C-state table, compiled from source.
  bc250AcpiOverride = pkgs.runCommand "bc250-acpi-override.cpio"
    {
      nativeBuildInputs = [ pkgs.cpio pkgs.acpica-tools ];
    } ''
    mkdir -p kernel/firmware/acpi
    iasl -p kernel/firmware/acpi/SSDT-PST ${bc250AcpiFix}/SSDT-PST.dsl
    iasl -p kernel/firmware/acpi/SSDT-CST ${bc250AcpiFix}/SSDT-CST.dsl
    find kernel -exec touch -h -d @1 {} +
    find kernel -print0 | sort -z | cpio --null --reproducible -o -H newc > "$out"
  '';
in

{
  boot = {
    initrd.prepend = [ "${bc250AcpiOverride}" ];
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
      temperature.throttling = false;
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
