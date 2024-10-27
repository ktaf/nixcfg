{ config, pkgs, ... }: {

  programs.alacritty = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.alacritty);
    settings = {
      window = {
        decorations = "None";
        opacity = 0.6;
        padding = {
          x = 3;
          y = 3;
        };
      };
      font = {
        size = 10;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
        };
      };
      colors = {
        transparent_background_colors = true;
        primary = {
          background = "#112211";
        };
      };
      mouse = {
        hide_when_typing = true;
        bindings = [
          { mouse = "Right"; action = "Copy"; }
        ];
      };
      scrolling.history = 100000;
    };
  };
}
