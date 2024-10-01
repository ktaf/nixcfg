{ config, pkgs, inputs, ... }: {
  # Include the results of the hardware scan.
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ../../_modules/shell.nix
    ../../_modules/users.nix
    ../../_modules/gaming.nix
    ../../_modules/sway.nix
    ../../_modules/yubikey.nix
    ../../_modules/vm.nix
    # ../../_modules/nvidia.nix
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
    nerdfonts
    ibm-plex
    hack-font
    fira-code
    fira-code-nerdfont
    fira-code-symbols
    jetbrains-mono
  ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    kernelPackages = pkgs.linuxPackages_6_8; # pkgs.linuxPackages_latest
  };

  # Set your time zone.
  time.timeZone = "Europe/Tallinn";
  location.provider = "geoclue2";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  #swaylock pass verify
  security = {
    pam.services.swaylock = { };
    rtkit.enable = true;
  };

  hardware = {
    pulseaudio = {
      enable = false;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth = { enable = true; };
    opengl.extraPackages = with pkgs;
      [
        # trying to fix `WLR_RENDERER=vulkan sway`
        vulkan-validation-layers
      ];
  };

  # XDG Configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];
    wlr = {
      enable = true;
      # settings = {
      #   screencast = {
      #     output_name = "eDP-1";
      #     max_fps = 30;
      #     chooser_type = "simple";
      #     chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      #   };
      # };
    };
  };

  # List services that you want to enable:
  services = {
    #emojis
    gollum.emoji = true;
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      displayManager.lightdm.enable = false;
      xkb = {
        layout = "us,ir";
        variant = "";
        options = "grp:alt_shift_toggle";
      };
    };
    #Flatpak
    flatpak.enable = true;
    # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    #locate
    # locate.enable = true;

    # Enable Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      #isDefault
      wireplumber.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable the Bluethooth daemon.
    blueman.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    dbus = {
      enable = true;
      packages = with pkgs; [ dconf ];
    };

    #tlp
    tlp = {
      enable = true;
      settings = {
        PCIE_ASPM_ON_BAT = "powersupersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_MAX_PERF_ON_AC = "100";
        CPU_MAX_PERF_ON_BAT = "60";
        STOP_CHARGE_THRESH_BAT1 = "95";
        STOP_CHARGE_THRESH_BAT0 = "95";
      };
    };

    #auto-cpufreq
    auto-cpufreq.enable = true;

    #upower dbus
    upower.enable = true;

    gnome = {
      # Solve 'org.freedesktop.secrets' error
      gnome-keyring.enable = true;
      # Solve AT-SPI error
      at-spi2-core.enable = true;
    };
    # Enable Firmware manager
    fwupd = {
      enable = true;
      package = pkgs.fwupd;
    };
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking = {
    networkmanager.enable = true;

    hostName = "x1g12";

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
