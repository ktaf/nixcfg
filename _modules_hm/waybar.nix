{ ... }:{

  programs.waybar = {
    enable = true;
    systemd.target = "hyprland-session.target";
    systemd.enable = true;
    style = builtins.readFile ../.config/waybar/style.css;
  };
}
