{ pkgs, ... }:

{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';

  systemd.services.walter-power = {
    description = "Walter CPU energy preference";
    wantedBy = [ "multi-user.target" ];
    after = [ "cpufreq.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        echo balance_power > "$policy/energy_performance_preference"
      done
    '';
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime ];
  };
}
