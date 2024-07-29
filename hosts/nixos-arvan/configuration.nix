{ config, pkgs, inputs, user, ... }: {
  # Include the results of the hardware scan.
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    ../../modules/shell.nix
    # ../../modules/vm.nix
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
  environment.systemPackages = with pkgs; [ git wget fzf ];

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Kourosh";
    extraGroups = [
      "networkmanager"
      "wheel"
      "qemu-libvirtd"
      "libvirtd"
      "kvm"
      "wheel"
      "disk"
      "docker"
      "input"
      "systemd-journal"
      "network"
      "davfs2"
    ];
    packages = with pkgs; [
      linux-firmware
      sshpass
      htop
      linuxHeaders
      go
      openssl
      unzip
      python3Full
      python311Packages.pip
      gnumake
      gcc
      glib
      cmake
    ];
  };
  networking = {
    networkmanager.enable = true;

    hostName = "nixos-arvan";

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