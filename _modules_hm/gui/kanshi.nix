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
              mode = "1920x1200@60.026Hz";
              position = "3440,240";
            }
            {
              criteria = "Dell Inc. DELL S3422DWG FSF4KK3";
              mode = "3440x1440@99.982Hz";
              position = "0,0";
            }
            # exec if grep -q open /proc/acpi/button/lid/LID0/state; then swaymsg output eDP-1 enable; else swaymsg output eDP-1 disable; fi
          ];
        };
      }
      {
        profile = {
          name = "office-docked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1200@60.026Hz";
              position = "3440,240";
            }
            {
              criteria = "Dell Inc. DELL S3423DWC C74VNH3";
              mode = "3440x1440@99.98Hz";
              position = "0,0";
            }
            # exec if grep -q open /proc/acpi/button/lid/LID0/state; then swaymsg output eDP-1 enable; else swaymsg output eDP-1 disable; fi
          ];
        };
      }
      {
        profile = {
          name = "mobile";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1200@60.026Hz";
              position = "0,0";
            }
          ];
        };
      }
    ];
  };
}



