{ pkgs, user, ... }:

{
  systemd.user = {
    targets.sway-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  };

  nixpkgs = { config = { allowUnfree = true; }; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";

    packages = with pkgs; [
      anydesk
      awscli2
      bat
      bitwarden
      cifs-utils
      curl
      dig
      dmidecode
      dnscontrol
      docker-compose
      elinks
      eza # better ls command
      zoxide # better cd command
      ffmpeg
      fluxcd
      fwupd
      fzf
      gnome.gnome-keyring
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
      openfortivpn
      openh264
      openra
      pciutils
      qbittorrent
      qdigidoc
      qflipper
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
