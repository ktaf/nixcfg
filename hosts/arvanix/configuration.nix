{ pkgs, inputs, user, ... }: {
  # Include the results of the hardware scan.
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ./network.nix
    ../../_modules/shell.nix
    # ../../_modules/vm.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
      # Enable binary caches for faster downloads
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [
        "https://cache.nixos.org"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 8d";
    };
  };

  # Fonts (minimal set for server)
  fonts.packages = with pkgs; [
    dejavu_fonts
  ];

  # Bootloader
  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
        configurationLimit = 3;
      };
    };
    kernelPackages = pkgs.linuxPackages_6_15; # pkgs.linuxPackages_latest
  };

  # Set your time zone and locale
  time.timeZone = "Asia/Tehran";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Services
  services = {
    openssh = {
      enable = true;
      # Harden SSH configuration
      settings = {
        # PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };
    zerotierone = {
      enable = true;
      joinNetworks = ["8286ac0e471570c2"];
       };
    # Enable fail2ban for additional security
    # fail2ban = {
    #   enable = false;
    #   maxretry = 5;
    #   ignoreIP = [
    #     "127.0.0.1/8"
    #     "::1/128"
    #     # Add your trusted IP ranges here
    #   ];
    # };
  };

  # Virtualization (Docker for containerization)
  virtualisation = {
    docker = {
      enable = true;
      # Enable rootless mode for better security
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [
      "wheel"
      "docker"
      "systemd-journal"
    ];
    # openssh.authorizedKeys.keys = [
    #   # Add your SSH public key here
    #   "ssh-rsa AAAAB...your_public_key_here"
    # ];
    packages = with pkgs; [
      htop
      openssl
      unzip
      git
      wget
      vim
      curl
      dnsutils
      fzf
      fd
      eza
    ];
  };

  system.stateVersion = "25.05";
}
