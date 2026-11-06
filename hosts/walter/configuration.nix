{ config, pkgs, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./gpu-unlock.nix
    ./llama-cpp.nix
    ./vllm.nix
    ../../_modules/shell.nix
    ../../_modules/git.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_7_3;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nixpkgs.config = {
    allowUnfree = true;
    cudaCapabilities = [ "8.6" ];
  };

  services = {
    fwupd.enable = true;
    thermald.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
    smartd = {
      enable = true;
      autodetect = true;
    };
  };

  time.timeZone = "Europe/Tallinn";
  i18n.defaultLocale = "en_GB.UTF-8";

  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    bat
    eza
    git
    vim
    curl
    wget
    unzip
    openssl
    htop
    pciutils
    ethtool
    smartmontools
    lm_sensors
    fastfetch
    config.boot.kernelPackages.turbostat
    powertop
    nvme-cli
    intel-gpu-tools
    libva-utils
    rsync
    iperf
    docker-compose
    compsize
  ];

  system.stateVersion = "26.05";
}
