{ config, pkgs, ... }: {
  # Include the results of the hardware scan.
  imports = [
    ./hardware-configuration.nix
    ./modules/shell.nix
    ./modules/users.nix
    ./modules/nvidia.nix
    ./modules/gaming.nix
    ./modules/sway.nix
    ./modules/vm.nix
    # ./modules/symlinks.nix
  ];

  nix = {
    ## From flake-utils-plus
    generateNixPathFromInputs = true;
    generateRegistryFromInputs = true;
    linkInputs = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false; # remove git warnings
    };
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    # # Added to contorl acpi events, keep version same as kernel #in_triage
    linuxKernel.packages.linux_6_5.acpi_call
  ];

  #fonts
  fonts.packages = with pkgs; [
    font-awesome
    (nerdfonts.override {
      fonts = [ "IBMPlexMono" "Hack" "FiraCode" "JetBrainsMono" ];
    })
  ];
  #emojis
  services.gollum.emoji = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_6_5; # pkgs.linuxPackages_latest

  # Set your time zone.
  time.timeZone = "Europe/Tallinn";
  location.provider = "geoclue2";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

  };

  services.xserver.displayManager.lightdm.enable = false;

  #swaylock pass verify
  security.pam.services.swaylock = { };

  #Flatpak
  services.flatpak.enable = true;
  #locate
  services.locate.enable = true;

  # Enable sound with pipewire.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  hardware.pulseaudio = {
    enable = false;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    #isDefault
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.dbus.enable = true;
  # XDG Configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the Bluethooth daemon.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.thermald.enable = true;

  #tlp
  services.tlp = {
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
  services.auto-cpufreq.enable = true;

  #upower dbus
  services.upower.enable = true;

  # Enable Firmware manager
  services.fwupd = {
    enable = true;
    package = pkgs.fwupd;
  };

  # Solve AT-SPI error
  services.gnome.at-spi2-core.enable = true;

  # This is needed for FortinetSSL VPN 
  environment.etc."ppp/options".text = "ipcp-accept-remote";

  networking = {
    networkmanager.enable = true;

    hostName = "xps9510";

    useDHCP = false;
    interfaces = {
      "enp0s13f0u4u4".useDHCP = true;
      "wlp0s20f3".useDHCP = true;
    };

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
  system.stateVersion = "23.11"; # Did you read the comment?
}
