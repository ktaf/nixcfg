{ config, lib, pkgs, ... }: {
  # Enable smartcard daemon, to read TOPT tokens from yubikey
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];
  environment = {
    systemPackages = with pkgs; [
      gnupg
      pcsctools
      # pinentry
      # pinentry-qt
      pinentry-gnome
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      yubikey-manager-qt
      yubico-piv-tool
      # yubioath-flutter
    ];
    shellInit = ''
      gpg-connect-agent /bye
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';
  };
  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
      settings = {
        default-cache-ttl = 900;
        max-cache-ttl = 999999;
      };
    };
  };
}
