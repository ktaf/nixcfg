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

  nixpkgs.config.allowUnfree = true;

  # Minimal fonts for server
  fonts.packages = with pkgs; [ dejavu_fonts ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_18;
  };

  # Localization
  time.timeZone = "Europe/Tallinn";
  i18n.defaultLocale = "en_GB.UTF-8";

  environment.systemPackages = with pkgs; [
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

    # Gaming diagnostics
    mesa
    mesa-demos
    mesa.drivers
    vulkan-loader
    vulkan-tools
    libGL
    libGLU

    # System monitoring and hardware tools
    pciutils
    ethtool
    smartmontools
    lm_sensors
    neofetch
    powertop
  ];

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [
      "networkmanager"
      "wheel"
      # graphics/input/audio access for Steam/Gamescope
      "video"
      "render"
      "input"
      "audio"
    ];
  };

  # Controllers / input
  hardware.uinput.enable = true;
  services.udev.packages = with pkgs; [ game-devices-udev-rules ];

  # Audio (Steam/Proton friendly)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # No display manager: autologin on tty1 (Jovian autostart handles launching Steam UI)
  services.getty.autologinUser = user;

  # Jovian (Steam Deck UI / Gaming Mode)
  jovian = {
    hardware = {
      has.amd.gpu = true;
    };

    steam = {
      enable = true;
      autoStart = true;
      user = user;
      updater.splash = "vendor";
      desktopSession = "gamescope-wayland"; # == desktopSession = null;
    };

    steamos.useSteamOSConfig = true;
  };

  system.stateVersion = "25.11";
}
