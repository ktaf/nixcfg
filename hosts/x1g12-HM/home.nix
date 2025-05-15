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
      "dotnet-runtime-wrapped-6.0.36"
      "dotnet-runtime-6.0.36"
      "dotnet-sdk-wrapped-6.0.428"
      "dotnet-sdk-6.0.428"
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
    stateVersion = "25.05";

    sessionVariables = {
      # Wayland configuration
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland,x11,*";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # Graphics and performance
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_ACCELERATED = "1";
      MOZ_WEBRENDER = "1";

      GSK_RENDERER = "gl"; # Changed from cairo to gl for better performance
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";

      # XDG Base Directories
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_LIB_HOME = "$HOME/.local/lib";
      XDG_CACHE_HOME = "$HOME/.cache";

      # Default applications
      SHELL = "$HOME/.nix-profile/bin/zsh";
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
      (config.lib.nixGL.wrap google-chrome)
      grive2
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
      localstack
      minimodem
      mission-center
      nemo
      neofetch
      nix-zsh-completions
      nixgl.nixGLIntel
      nmap
      novnc
      obsidian
      okta-aws-cli
      ollama
      openh264
      openra
      pciutils
      polkit_gnome
      pre-commit
      pulseaudio
      python.pkgs.pip
      python312Packages.invoke
      python312Packages.pip
      python312Packages.tkinter
      python312Packages.usb-monitor
      python3Full
      qbittorrent
      qdigidoc
      remmina
      ripgrep
      s3cmd
      ssm-session-manager-plugin
      tdesktop
      tcptraceroute
      tenv
      terraform-docs
      tfautomv
      traceroute
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
      (config.lib.nixGL.wrap slack)
      (config.lib.nixGL.wrap vscode)
      (config.lib.nixGL.wrap zoom-us)
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
