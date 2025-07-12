{ pkgs, ... }: {

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
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
          family = "JetBrainsMono";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono";
        };
        italic = {
          family = "JetBrainsMono";
        };
      };
      colors = {
        transparent_background_colors = true;
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = "#000000";
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
