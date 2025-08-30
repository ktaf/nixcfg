{ pkgs, ... }:
{

  imports = [
    ./alacritty.nix
    ./zsh.nix
    # ./yubikey.nix
  ];

  home.packages = with pkgs; [
    font-awesome
    unicode-emoji
    rofimoji
    ibm-plex
    iosevka
    hack-font
    fira-code
    fira-code-symbols
    jetbrains-mono
    cascadia-code
    comfortaa
    nerd-fonts.hack
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.cousine
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.symbols-only
    nerd-fonts.sauce-code-pro
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.zed-mono
    nerd-fonts.iosevka-term-slab
    nerd-fonts.monoid
    nerd-fonts.hasklug
    nerd-fonts.inconsolata
    nerd-fonts.mononoki
    nerd-fonts.hurmit
    material-icons
    material-design-icons

    gnupg
    gnupg-pkcs11-scd
    pcsc-tools
    eid-mw
    scmccid
    opencryptoki

    # yubikey-personalization
    # yubikey-personalization-gui
    # yubikey-manager
    # yubikey-manager-qt
    # yubico-piv-tool
    # yubioath-flutter

  ];
  # Allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;
  programs.nix-index.enable = true;
}
