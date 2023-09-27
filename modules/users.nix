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
      waybar # topbar
      kanshi # laptop dncies
      rofi
      mako
      rofimoji # Drawer + notifications
      jellyfin-ffmpeg # multimedia libs
      viewnior # image viewr
      pavucontrol # Volume control
      font-awesome
      gnome-text-editor
      gnome.file-roller
      gnome.gnome-font-viewer
      gnome.gnome-calculator
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
      imagemagick
      flameshot
      bluez
      blueman
      htop
      jetbrains-mono
      libva
      linuxHeaders
      lxappearance
      networkmanagerapplet
      noto-fonts-emoji
      nvidia-vaapi-driver
      libva-utils
      glxinfo
      go
      openssl
      unzip
      polkit_gnome
      python3Full
      python311Packages.pip
      xdg-desktop-portal-wlr
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      electron
      xdg-utils # for opening default programs when clicking links
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      wdisplays # tool to configure displays
      ####GTK Customization####
      nordic
      gnome.gnome-themes-extra
      papirus-icon-theme
      gtk3
      glib # gsettings
      xcur2png
      rubyPackages.glib2
      libcanberra-gtk3 # notification sound
      #########System#########
      google-chrome
      firefox
      libnotify
      poweralertd
      dbus
    ];
  };

  # QT
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  #thunar
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-dropbox-plugin
      thunar-media-tags-plugin
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  #gnome outside gnome
  programs.dconf.enable = true;

  #Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us,ir";
    xkbVariant = "latitude";
    xkbOptions = "grp:alt_shift_toggle";
  };

  # User etc/
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=System/Desktop
    DOWNLOAD=System/Downloads
    TEMPLATES=System/Templates
    PUBLICSHARE=System/Public
    DOCUMENTS=System/Documents
    MUSIC=Media/music
    PICTURES=Media/photos
    VIDEOS=Media/video 
  '';
}
