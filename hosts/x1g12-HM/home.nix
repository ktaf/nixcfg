{ config, pkgs, nixGL, ... }:
let
  user = "kourosh";
in
{
  nixGL = {
    packages = nixGL.packages;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Ease usage on non-NixOS installations
  targets.genericLinux.enable = true;

  services = {
    systembus-notify.enable = true;
    blueman-applet.enable = true;
  };

  systemd.user.sessionVariables = {
    EDITOR = "code";
  };
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "25.05";

    sessionVariables = {
      # Wayland specific
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = 1;
      MOZ_ENABLE_WAYLAND = 1;
      GDK_BACKEND = "wayland";
      GSK_RENDERER = "cairo";
      XCURSOR_THEME = "deafult";
      XCURSOR_SIZE = 24;
      SDL_VIDEODRIVER = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";

      # Additional compatibility variables
      CLUTTER_BACKEND = "wayland";
      WINIT_UNIX_BACKEND = "wayland";
      WLR_DRM_NO_ATOMIC = "1";
      INTEL_DEBUG = "noccs";

      # Set default applications
      SHELL = "$HOME/.nix-profile/bin/zsh";
      TERMINAL = "alacritty";
      VISUAL = "code";
      EDITOR = "code";
      BROWSER = "google-chrome-stable";
      PAGER = "less";
      # Set XDG directories
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_LIB_HOME = "$HOME/.local/lib";
      XDG_CACHE_HOME = "$HOME/.cache";
      # Respect XDG directories
      DOCKER_CONFIG = "$HOME/.config/docker";
      LESSHISTFILE = "-"; # Disable less history
      # # SSH Agent
      # SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";

      # GTK specific
      GTK_USE_PORTAL = 1;

      # Qt specific
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      QT_WAYLAND_FORCE_DPI = "physical";

      # PipeWire related (for screen sharing)
      PIPEWIRE_RUNTIME_DIR = "/run/user/$(id -u)";
    };

    packages = with pkgs; [
      awscli2
      bat
      bluez
      blueman
      cmake
      cpio
      curl
      dbus
      dig
      elinks
      eza # better ls command
      zoxide # better cd command
      ffmpeg
      fluxcd
      fzf
      google-chrome
      grive2
      htop
      jq
      kind
      krew
      kubectl
      kubectx
      kubernetes-helm
      libdigidocpp
      libudfread
      libinput
      libdrm
      virt-manager
      libxkbcommon
      # localstack
      nemo
      neofetch
      nix-zsh-completions
      nmap
      obsidian
      ollama
      open-webui
      openh264
      openra
      pciutils
      pulseaudio
      qbittorrent
      qdigidoc
      remmina
      ripe-atlas-tools
      ripgrep
      s3cmd
      slack
      tenv # terraform      # terragrunt
      terraform-docs
      tdesktop
      tfautomv
      traceroute
      tcptraceroute
      trousers
      vsh
      vscode
      winbox
      which
      whois
      wsdd
      polkit_gnome

      minimodem
      xfontsel

      novnc
      wayvnc
      directvnc

      okta-aws-cli
      _1password-gui
      python3Full
      python312Packages.pip
      python312Packages.invoke
      pre-commit
      google-cloud-sdk-gce

      dbeaver-bin

      (config.lib.nixGL.wrap pkgs.zoom-us)
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

}
