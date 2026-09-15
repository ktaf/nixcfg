{ pkgs, ... }:

{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="cpu", ATTR{cpufreq/energy_performance_preference}="balance_power"
  '';

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

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" "/data" "/media" "/fast" ];
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
