{ pkgs, inputs, user, ... }: {
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ./network.nix
    ../../_modules/shell.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [ "https://cache.nixos.org" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 8d";
    };
  };

  # Minimal fonts for server
  fonts.packages = with pkgs; [ dejavu_fonts ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_16;
  };

  # Localization
  time.timeZone = "Europe/Tallinn";
  i18n.defaultLocale = "en_GB.UTF-8";

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Core utilities
      bat
      eza
      htop
      git
      vim
      curl
      wget
      unzip
      openssl
      # System monitoring and hardware tools
      pciutils
      ethtool
      smartmontools
      lm_sensors
      neofetch
      linuxKernel.packages.linux_6_16.turbostat
      powertop
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services = {
    fwupd.enable = true;
    thermald.enable = true;

    # Immich photo management
    immich = {
      enable = true;
      host = "192.168.2.16";
      port = 2283;
      machine-learning.enable = true;
      database.enable = true;
    };
  };

  # Power management for server efficiency
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  system.stateVersion = "25.05";
}
