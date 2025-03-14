{ config, pkgs, nixGL, ... }:
let
  user = "kourosh";
in
{
  nixGL = {
    packages = nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "dotnet-runtime-wrapped-6.0.36"
        "dotnet-runtime-6.0.36"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-6.0.428"
        "python-2.7.18.8"
      ];
    };
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
      _JAVA_AWT_WM_NONREPARENTING = "1";
      # Hardware rendering
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_ACCELERATED = "1";
      MOZ_WEBRENDER = "1";

      GDK_BACKEND = "wayland";
      GSK_RENDERER = "gl"; # Changed from cairo to gl for better performance
      XCURSOR_THEME = "default";
      XCURSOR_SIZE = "24";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      ELECTRON_OZONE_PLATFORM_HINT = "auto";

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

      # # Qt specific
      # QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      # QT_WAYLAND_FORCE_DPI = "physical";

      # PipeWire related (for screen sharing)
      PIPEWIRE_RUNTIME_DIR = "/run/user/$(id -u)";
    };

    packages = with pkgs; [
      avahi
      awscli2
      bat
      bluez
      blueman
      cmake
      cpio
      curl
      dbus
      dig
      docker-compose
      elinks
      eza # better ls command
      zoxide # better cd command
      ffmpeg
      fluxcd
      fzf
      (config.lib.nixGL.wrap pkgs.google-chrome)
      grive2
      htop
      intel-gmmlib
      jq
      kind
      krew
      kubectl
      kubectx
      kubernetes-helm
      libdigidocpp
      libudfread
      libinput
      virt-manager
      libxkbcommon
      # localstack
      mission-center
      nemo
      neofetch
      nixgl.nixGLIntel
      nix-zsh-completions
      nmap
      obsidian
      ollama
      # open-webui
      openh264
      openra
      pciutils
      pulseaudio
      qbittorrent
      qdigidoc
      remmina
      # ripe-atlas-tools
      ripgrep
      s3cmd
      (config.lib.nixGL.wrap pkgs.slack)
      tenv # terraform      # terragrunt
      terraform-docs
      tdesktop
      tfautomv
      traceroute
      tcptraceroute
      trousers
      vsh
      (config.lib.nixGL.wrap pkgs.vscode)
      winbox
      which
      whois
      wsdd
      polkit_gnome
      usbview
      v4l-utils
      libv4l
      python312Packages.usb-monitor
      usbrip

      minimodem
      xfontsel

      novnc
      wayvnc
      # directvnc

      okta-aws-cli
      _1password-gui
      # poetry
      python3Full
      python.pkgs.pip
      python312Packages.pip
      python312Packages.invoke
      pre-commit
      google-cloud-sdk-gce
      ssm-session-manager-plugin

      dbeaver-bin

      hugo

      vkmark
      # vpl-gpu-rt 
      # mkl # Installed via apt Intel® oneAPI Base Toolkit

      vuls
      # xsane
      # epsonscan2
      zerotierone
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
