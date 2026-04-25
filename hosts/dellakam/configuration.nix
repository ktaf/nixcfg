{ lib, pkgs, inputs, user, ... }: {
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ./network.nix
    ../../_modules/shell.nix
    ../../_modules/git.nix
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
    kernelPackages = pkgs.linuxPackages_7_0;
  };

  # Localization
  time.timeZone = "Europe/Tallinn";
  i18n.defaultLocale = "en_GB.UTF-8";

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [ "networkmanager" "wheel" "docker" "win" ];
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
      fastfetch
      linuxKernel.packages.linux_7_0.turbostat
      powertop

      netbird
      iperf
      docker-compose
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services = {
    fwupd.enable = true;
    thermald.enable = true;

    # Immich photo management
    immich = {
      enable = true;
      host = "192.168.2.27";
      port = 2283;
      machine-learning.enable = true;
      database.enable = true;
    };

    jellyfin.enable = true;
    seerr.enable = true;
    sabnzbd.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = true;
    flaresolverr.enable = true;
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    transmission = {
      enable = true;
      group = "win";
      downloadDirPermissions = "2775";
      settings = {
        download-dir = "/data/downloads/complete";
        incomplete-dir = "/data/downloads/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "/data/downloads/watch";
        watch-dir-enabled = true;
        rpc-bind-address = "127.0.0.1";
        rpc-port = 8081;
        umask = "002";
      };
    };
  };

  systemd.services = {
    bazarr.serviceConfig = {
      SupplementaryGroups = [ "win" ];
      UMask = lib.mkForce "0002";
    };
    jellyfin.serviceConfig = {
      SupplementaryGroups = [ "win" ];
      UMask = lib.mkForce "0002";
    };
    transmission = {
      requires = [ "transmission-setup.service" ];
      serviceConfig = {
        UMask = lib.mkForce "0002";
      };
    };
    radarr.serviceConfig = {
      SupplementaryGroups = [ "win" ];
      UMask = lib.mkForce "0002";
    };
    sabnzbd.serviceConfig = {
      SupplementaryGroups = [ "win" ];
      UMask = lib.mkForce "0002";
    };
    sonarr.serviceConfig = {
      SupplementaryGroups = [ "win" ];
      UMask = lib.mkForce "0002";
    };
  };

  # Power management for server efficiency
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  virtualisation = {
    docker = {
      enable = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/downloads 2775 win win -"
    "z /data/downloads 2775 win win -"
  ];

  system.stateVersion = "26.05";
}
