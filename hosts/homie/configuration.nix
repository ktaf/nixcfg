{ pkgs, inputs, user, ... }: {
  # Include the results of the hardware scan.
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

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_15;
  };

  # Set your time zone.
  time.timeZone = "Europe/Tallinn";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      bat
      eza
      htop
      openssl
      unzip
      git
      wget
      vim
      curl
      powertop
      pciutils
      ethtool
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List services that you want to enable:
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
    fwupd = {
      enable = true;
      package = pkgs.fwupd;
    };
    # Immich
    immich = {
      enable = true;
      port = 2283;
      accelerationDevices = null; # Enable hardware acceleration for all devices
    };
    nginx = {
      enable = true;
      virtualHosts."immich.homie.lan" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:2283";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };
    };
  };

  users.users.immich.extraGroups = [ "video" "render" ];

  fileSystems."/var/lib/immich" = {
    device = "/data/immich";
    options = [ "bind" "nofail" ];
  };

  system.stateVersion = "25.11";
}
