{ pkgs, inputs, user, ... }: {
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ./network.nix
    ./steamos.nix
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

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_18;
    kernelPatches = [
      {
        name = "bc250-40cu-amdgpu";
        patch = ./patches/bc250-40cu-amdgpu.patch;
      }
    ];
    kernelParams = [
      "amdgpu.bc250_cc_write_mode=3"
    ];
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
    python3

    # System monitoring and hardware tools
    pciutils
    ethtool
    smartmontools
    lm_sensors
    fastfetch
    powertop
    usbutils
    usb-modeswitch # usb_modeswitch -KW -v 0bda -p 1a2b
    umr
    bluez
  ];

  services.udev.extraRules = ''
    # Force-switch the RTL8851BU dongle out of its fake CD-ROM mode.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -KW -v 0bda -p 1a2b"
  '';

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

  system.stateVersion = "26.05";
}
