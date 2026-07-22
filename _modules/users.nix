{ pkgs, user, ... }:

{

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
      "audio"
      "video"
      "input"
      "systemd-journal"
      "network"
      "davfs2"
    ];
    packages = with pkgs; [
      auto-cpufreq
      nemo-with-extensions
      nemo-qml-plugin-dbus
      nemo-python
      waybar # topbar
      kanshi # laptop dncies
      rofi
      mako # notification system developed by swaywm maintainer
      rofimoji # Drawer + notifications
      # jellyfin-ffmpeg # multimedia libs
      viewnior # image viewr
      pavucontrol # Volume control
      font-awesome
      gnome-text-editor
      file-roller
      gnome-font-viewer
      gnome-calculator
      vlc # Video player
      amberol # Music player
      cava # Sound Visualized
      wf-recorder # Video recorder
      sway-contrib.grimshot # Screenshot
      ffmpegthumbnailer # thumbnailer
      playerctl # play,pause..
      pamixer # mixer
      brightnessctl # Brightness control
      wev
      alsa-lib
      alsa-utils
      flac
      pulsemixer
      peek
      linux-firmware
      sshpass
      # imagemagick
      flameshot
      bluez
      blueman
      htop
      #intune-portal
      libva
      linuxHeaders
      lshw
      lxappearance
      networkmanagerapplet
      mesa-demos
      go
      openssl
      unzip
      usbutils
      polkit_gnome
      # python3Full
      # python311Packages.pip
      xdg-desktop-portal-wlr
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      direnv
      nix-direnv
      gnumake
      gcc
      glib
      cmake
      #########System#########
      google-chrome
      libnotify
      poweralertd
      dbus
      eza
      bat
      vscode
      git
    ];
  };

  # QT
  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "qt5ct";
  };

  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.intune.enable = true;
  programs.seahorse.enable = true;


  #Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };
}
