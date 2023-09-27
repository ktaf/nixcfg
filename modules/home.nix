{ config, pkgs, user, ... }:

{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.05";

  systemd.user = {
    targets.sway-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      # allowUnfreePredicate = (_: true);
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    android-studio
    android-tools
    anydesk
    awscli2
    bat
    bitwarden
    chiaki
    curl
    dig
    dmidecode
    elinks
    eza
    fluxcd
    flutter
    fwupd
    fzf
    gnome.gnome-keyring
    google-cloud-sdk
    grive2
    imv
    jq
    kind
    krew
    kubectl
    kubectx
    kubernetes-helm
    libdigidocpp
    libudfread
    microsoft-edge
    neofetch
    nix-zsh-completions
    nmap
    obsidian
    opencryptoki
    openfortivpn
    qdigidoc
    remmina
    ripgrep
    s3cmd
    slack
    terraform
    tdesktop
    tfautomv
    trousers
    vscode
    zoom
  ];

  home.sessionVariables = {
    EDITOR = "code";
    KUBE_EDITOR = "code -w";
    BROWSER = "google-chrome-stable";
    TERMINAL = "alacritty";
    # GTK_IM_MODULE = "fcitx5";
    # QT_IM_MODULE = "fcitx5";
    # XMODIFIERS = "@im=fcitx5";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_SCALE_FACTOR = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    GBM_BACKEND = "nvidia-drm";
    CLUTTER_BACKEND = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_RENDERER = "vulkan";
    # __NV_PRIME_RENDER_OFFLOAD = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
  };

  programs.git = {
    enable = true;
    userName = "ktaf";
    userEmail = "kouroshtaf@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "code";
      protocol.keybase.allow = "always";
      pull.rebase = "false";
    };
  };

  #Gtk 
  gtk = {
    enable = true;
    font.name = "Hack Nerd 10";
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

}
