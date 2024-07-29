{ config, pkgs, inputs, user, ... }: {
  # Include the results of the hardware scan.
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ../../_modules/shell.nix
    # ../../_modules/vm.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false; # remove git warnings
    };
    gc = {
      automatic = true;
      dates = "daily";
    };
  };
  #fonts
  fonts.packages = with pkgs; [
    font-awesome
  ];
  # Bootloader.
  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
        configurationLimit = 3;
      };
    };
    kernelPackages = pkgs.linuxPackages_6_10; # pkgs.linuxPackages_latest
  };

  # Set your time zone.
  time.timeZone = "Asia/Tehran";
  location.provider = "geoclue2";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

# List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };
  virtualisation = {
    docker.enable = true;
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [
      "networkmanager"
      "wheel"
      "wheel"
      "disk"
      "docker"
      "systemd-journal"
      "network"
    ];
    packages = with pkgs; [
      htop
      openssl
      unzip
      git
      wget
      fzf
    ];
  };
  networking = {
    networkmanager.enable = true;

    hostName = "arvanix";

    # Custom DNS
    resolvconf.enable = false;
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    firewall = {
      enable = false;
      ##Open ports in the firewall.
      # allowedTCPPorts = [ ... ];
      ##For Chromecast from chrome
      # allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
      # allowedUDPPorts = [ 51820 ];
    };
  };
  system.stateVersion = "24.05"; # Did you read the comment?

}