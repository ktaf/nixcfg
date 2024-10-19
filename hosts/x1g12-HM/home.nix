{ config, pkgs, lib, inputs, user, ... }:
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

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";

    sessionVariables = {
      GSK_RENDERER = "cairo";
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
      fwupd
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


services = {
  blueman-applet.enable = true;
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
