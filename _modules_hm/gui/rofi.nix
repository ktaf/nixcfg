{ config, ... }: {

  home.file."${config.home.homeDirectory}/.config/rofi/config.rasi".source = ../../.config/rofi/config.rasi;
  home.file."${config.home.homeDirectory}/.config/rofi/colors.rasi".source = ../../.config/rofi/colors.rasi;
  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font 11.6";
  };
}
