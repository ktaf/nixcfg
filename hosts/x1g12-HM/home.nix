{ config, pkgs, nixGL, ... }:
let
  user = "kourosh";
in
{
  # TODO: remove when https://github.com/nix-community/home-manager/pull/5355 gets merged:
  imports = [
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
      sha256 = "1krclaga358k3swz2n5wbni1b2r7mcxdzr6d7im6b66w3sbpvnb3";
    })
  ];
  # {
  #   systemd.user = {
  #     targets.sway-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  #   };

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
    stateVersion = "24.11";

    sessionVariables = {
      GDK_BACKEND = "wayland";
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
      cloudflare-warp
      gnomeExtensions.cloudflare-warp-toggle
      gnomeExtensions.cloudflare-warp-indicator
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
