{ ... }:{

  programs.rofi = {
    enable = true;
    # configPath = " ../.config/rofi/config.rasi";
    theme = builtins.readFile ../../.config/rofi/themes/catppuccin-mocha.rasi;
  };
}
