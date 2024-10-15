{ pkgs, ... }:{

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # settings = [
    #    {
    #      config = builtins.readFile ../.config/waybar/config;
    #    }
    #    ];
    style = builtins.readFile ../.config/waybar/style.css;
  };
}
