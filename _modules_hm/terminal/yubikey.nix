{ ... }:{

    # shellInit = ''
    #   gpg-connect-agent /bye
    #   export GPG_TTY="$(tty)"
    #   export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    #   gpgconf --launch gpg-agent
    # '';
  programs.gpg = {
    enable = true;
  };
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      # pinentryPackage = pkgs.pinentry-gnome3;
      # settings = {
      #   ttyname = "$GPG_TTY";
      #   default-cache-ttl = 900;
      #   max-cache-ttl = 999999;
      # };
    };
  };
}


