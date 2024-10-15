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

    packages = with pkgs; [
      (config.lib.nixGL.wrap alacritty)
      awscli2
      bat
      curl
      dig
      docker-compose
      elinks
      eza # better ls command
      zoxide # better cd command
      ffmpeg
      fluxcd
      fwupd
      fzf
      gnome-keyring
      grive2
      jq
      kind
      krew
      kubectl
      kubectx
      kubernetes-helm
      libdigidocpp
      libudfread
      libinput
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

  # #Gtk 
  # gtk = {
  #   enable = true;
  #   font.name = "Hack Nerd 10";
  #   theme = {
  #     name = "Nordic";
  #     package = pkgs.nordic;
  #   };
  #   iconTheme = {
  #     name = "Papirus-Dark";
  #     package = pkgs.papirus-icon-theme;
  #   };
  # };
  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   package = config.lib.nixGL.wrap pkgs.hyprland;
  #   settings = {
  #     general = {
  #       gaps_in = 0;
  #       gaps_out = 0;
  #       border_size = 20;
  #     };
  #   };
  # };

}
