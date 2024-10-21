{ config, pkgs, inputs, ... }:
let
  user = "kourosh";
  nixGLIntel = inputs.nixGL.packages.${pkgs.system}.nixGLIntel;
in {
  imports = [
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
      sha256 = "01dkfr9wq3ib5hlyq9zq662mp0jl42fw3f6gd2qgdf8l8ia78j7i";
    })
  ];
# {
#   systemd.user = {
#     targets.sway-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
#   };

  nixGL.prefix = "${nixGLIntel}/bin/nixGLIntel";

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
    blueman-applet.enable = true;
    mpris-proxy.enable = true;
  };

  systemd.user.sessionVariables = {
    EDITOR = "code";
  };
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";

    sessionVariables = {
      GSK_RENDERER = "cairo";
      XCURSOR_SIZE = 24;
      SDL_VIDEODRIVER = "wayland";
      # Set default applications
      SHELL = "$HOME/.nix-profile/bin/zsh";
      TERMINAL = "kitty";
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

    };

    packages = with pkgs; [
      # (config.lib.nixGL.wrap kitty)
      awscli2
      bat
      bluez
      blueman
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
      neofetch
      nix-zsh-completions
      nmap
      obsidian
      ollama
      opencryptoki
      openh264
      openra
      pciutils
      pulseaudio
      pavucontrol
      qbittorrent
      qdigidoc
      remmina
      ripgrep
      s3cmd
      # samba4Full
      slack
      terraform
      tdesktop
      tfautomv
      trousers
      vsh
      vscode
      winbox
      which
      whois
      wsdd
      zoom
    ];
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

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

}
