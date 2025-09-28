{ config, pkgs, nixGL, ... }:
let
  user = "kourosh";
in
{
  nixGL = {
    packages = nixGL.packages;
    installScripts = [ "mesa" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "python-2.7.18.8"
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Ease usage on non-NixOS installations
  targets.genericLinux.enable = true;

  services = {
    systembus-notify.enable = true;
    blueman-applet.enable = true;
    trayscale.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "25.11";

    sessionVariables = {
      # Wayland configuration
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # Graphics and performance
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_ACCELERATED = "1";
      MOZ_WEBRENDER = "1";

      WLR_DRM_NO_ATOMIC = "1 sway";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER = "vulkan";
      __GLX_VENDOR_LIBRARY_NAME = "mesa";

      GSK_RENDERER = "gl"; # Changed from cairo to gl for better performance
      XCURSOR_THEME = "Adwaita";

      # XDG Base Directories
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
      XDG_LIB_HOME = "${config.home.homeDirectory}/.local/lib";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";

      # Default applications
      SHELL = "$HOME/.nix-profile/bin/zsh";
      TERM = "xterm-256color";
      TERMINAL = "alacritty";
      VISUAL = "code";
      EDITOR = "code";
      BROWSER = "google-chrome-stable";
      PAGER = "less";

      # Miscellaneous
      DOCKER_CONFIG = "$HOME/.config/docker";
      LESSHISTFILE = "-";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      PIPEWIRE_RUNTIME_DIR = "/run/user/$(id -u)";

      # Work
      KUBE_EDITOR = "code -w";
      TENV_DETACHED_PROXY = "false";
      TG_LOG_FORMAT = "bare";
      TERRAGRUNT_QUIET = "true";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
    };

    packages = with pkgs; [
      _1password-gui
      alpaca
      avahi
      awscli2
      bat
      blueman
      bluez
      cmake
      cpio
      curl
      dbus
      dbeaver-bin
      dig
      docker-compose
      elinks
      eza
      ffmpeg
      firecracker
      fluxcd
      fzf
      go
      google-chrome
      grive2
      gum
      htop
      hugo
      inframap
      intel-gmmlib
      jq
      kind
      krew
      kubectl
      kubectx
      kubernetes-helm
      libdigidocpp
      libinput
      libudfread
      libv4l
      libxkbcommon
      # localstack
      looking-glass-client
      minimodem
      mission-center
      moonlight-qt
      nemo
      neofetch
      nix-zsh-completions
      nixgl.nixGLIntel
      nmap
      novnc
      obsidian
      okta-aws-cli
      openh264
      pciutils
      polkit_gnome
      pre-commit
      pulseaudio
      python.pkgs.pip
      python312Packages.invoke
      python312Packages.pip
      python312Packages.tkinter
      python312Packages.usb-monitor
      python312
      qbittorrent
      qdigidoc
      remmina
      ripgrep
      s3cmd
      sshfs
      ssm-session-manager-plugin
      subnetcalc
      tdesktop
      tenv
      terraform-docs
      tfautomv
      trousers
      usbview
      usbrip
      v4l-utils
      virt-manager
      vkmark
      vsh
      wayvnc
      which
      whois
      winbox
      wsdd
      xfontsel
      zoxide
      slack
      vscode
      zoom-us
    ];
  };

  programs.git = {
    enable = true;
    userName = "ktaf";
    userEmail = "kourosh.tafreshi@bolt.eu";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "code";
      protocol.keybase.allow = "always";
      pull.rebase = "false";
      push.autoSetupRemote = true;
    };
  };

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';
  xdg.configFile."swaylock/config".text = ''
    image=${config.home.homeDirectory}/lockscreen.png
  '';
}
