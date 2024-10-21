{ pkgs, ... }:
{

    imports = [
        ./kitty.nix
        ./zsh.nix
        ./yubikey.nix
    ];

    home.packages = with pkgs; [
      font-awesome
      unicode-emoji
      rofimoji
      nerdfonts
      ibm-plex
      hack-font
      fira-code
      fira-code-nerdfont
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override {
        fonts = [
          "Hack"
          "FiraCode"
          "FiraMono"
          "CascadiaCode"
          "Cousine"
          "DroidSansMono"
          "JetBrainsMono"
          "SourceCodePro"
        ];})

      gnupg
      pcsctools
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      yubikey-manager-qt
      yubico-piv-tool
      yubioath-flutter

    ];
 # Allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;
  programs.nix-index.enable = true;
}