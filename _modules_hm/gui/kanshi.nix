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
              criteria = "eDP-1";
              mode = "1920x1200@60Hz";
              position = "3440,240";
            }
            {
              criteria = "Dell Inc. DELL S3422DWG FSF4KK3";
              mode = "3440x1440@99.98Hz";
              position = "0,0";
            }
          ];
          exec = [
            "[ $(cat /proc/acpi/button/lid/LID0/state | cut -f2 -d':' | tr -d '[:space:]') = closed ] && swaymsg output eDP-1 disable || swaymsg output eDP-1 enable"
          ];
        };
      }
      {
        profile = {
          name = "office-docked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1200@60Hz";
              position = "3440,240";
            }
            {
              criteria = "Dell Inc. DELL S3423DWC C74VNH3";
              mode = "3440x1440@99.98Hz";
              position = "0,0";
            }
          ];
          exec = [
            "[ $(cat /proc/acpi/button/lid/LID0/state | cut -f2 -d':' | tr -d '[:space:]') = closed ] && swaymsg output eDP-1 disable || swaymsg output eDP-1 enable"
          ];
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
