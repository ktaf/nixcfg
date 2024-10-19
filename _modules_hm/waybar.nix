{ pkgs, ... }:{

  programs.waybar = {
    enable = true;
    # systemd.enable = true;
    style = builtins.readFile ../.config/waybar/style.css;
  };
}
