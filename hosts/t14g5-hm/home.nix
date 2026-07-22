{ config, pkgs, ... }:
let
  user = "kourosh";
in
{
  imports = [
    ../../_modules/git.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "python-2.7.18.8"
      "python-2.7.18.12"
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Ease usage on non-NixOS installations
  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };

  services = {
    systembus-notify.enable = true;
    blueman-applet.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

    sessionVariables = {
      # Wayland configuration
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      # Used by the nixpkgs Chrome wrapper even outside NixOS.
      NIXOS_OZONE_WL = "1";
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
      AMD_VULKAN_ICD = "RADV"; # Explicit RADV for better perf
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

      # Python config
      # PYTHONDONTWRITEBYTECODE = "true";
      # PIP_REQUIRE_VIRTUALENV = "true";
      # POETRY_VIRTUALENVS_IN_PROJECT = "true";
    };

    packages = with pkgs; [
      bat
      blueman
      claude-code
      eza
      ffmpeg
      firecracker
      fzf
      go
      google-chrome
      htop
      inframap
      kind
      krew
      kubectl
      kubectx
      kubernetes-helm
      kubeseal
      libdigidocpp
      libinput
      libudfread
      libxkbcommon
      mesa-demos
      minimodem
      mission-center
      moonlight-qt
      ripgrep
      fastfetch
      nmap
      novnc
      obsidian
      openh264
      polkit_gnome
      pre-commit
      pulseaudio
      qdigidoc
      remmina
      sshfs
      subnetcalc
      telegram-desktop
      tenv
      terraform-docs
      tfautomv
      trousers
      usbview
      usbrip
      v4l-utils
      virt-manager
      vsh
      wayvnc
      whois
      winbox
      # wireshark
      xfontsel
      slack
      vscode
    ];
  };

  programs.git = {
    settings = {
      user.email = "kouroshtaf@gmail.com";
      core.editor = "code";
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
