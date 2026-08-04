{ ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "sway-session.target";
    settings = [
      {
        profile = {
          name = "home-docked";
          outputs = [
            {
              criteria = "HDMI-A-1";
              mode = "3840x1080@120.000Hz";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              mode = "1920x1200@60.002Hz";
              position = "3840,0";
            }
            # {
            #   criteria = "Samsung Electric Company Odyssey G93SC HNTX201462"; # DP
            #   mode = "5120x1440@240.000Hz";
            #   position = "0,0";
            # }
          ];
          # exec = [
          #   "[ $(cat /proc/acpi/button/lid/LID0/state | cut -f2 -d':' | tr -d '[:space:]') = closed ] && swaymsg output eDP-1 disable || swaymsg output eDP-1 enable"
          # ];
        };
      }
      {
        profile = {
          name = "office-docked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1200@60Hz";
              position = "0,406";
            }
            {
              criteria = "DP-2";
              mode = "3440x1440@100Hz";
              position = "1920,166";
            }
          ];
          # exec = [
          #   "[ $(cat /proc/acpi/button/lid/LID0/state | cut -f2 -d':' | tr -d '[:space:]') = closed ] && swaymsg output eDP-1 disable || swaymsg output eDP-1 enable"
          # ];
        };
      }
      {
        profile = {
          name = "mobile";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1200@60Hz";
              position = "0,0";
            }
          ];
        };
      }
    ];
  };
}
