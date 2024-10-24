{ ... }: {

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    style = builtins.readFile ../../.config/waybar/style.css;
  };
}
