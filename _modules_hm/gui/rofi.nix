{ ... }: {

  home.file."/home/kourosh/.config/rofi/config.rasi".source = ../../.config/rofi/config.rasi;
  home.file."/home/kourosh/.config/rofi/colors.rasi".source = ../../.config/rofi/colors.rasi;
  programs.rofi = {
    enable = true;
    font = "JetBrains Mono Nerd Font 11.6";
  };
}
