{ ... }: {

  programs.waybar = {
    enable = true;
    # Called in sway.nix
    # systemd = { 
    #   enable = true;
    #   target = "sway-session.target";
    # };
    style = builtins.readFile ../../.config/waybar/style.css;
    settings = {
      mainBar = {
        height = 32;
        margin = "0 0 0 0";
        layer = "bottom";
        position = "top";
        mod = "dock";
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        spacing = 3;

        modules-left = [
          "custom/launcher"
          "sway/workspaces"
          "cpu"
          "memory"
          "temperature"
          "disk"
        ];
        modules-center = [ "mpris" ];
        modules-right = [
          "clock"
          "backlight"
          "pulseaudio"
          "battery"
          "custom/cf-zt"
          "keyboard-state"
          "network"
          "bluetooth"
          "tray"
          "sway/language"
          "custom/power-menu"
        ];

        "sway/workspaces" = {
          format = "{icon}";
          "on-click" = "activate";
          "format-icons" = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
          "sort-by-number" = true;
        };

        bluetooth = {
          format = "";
          "format-off" = "󰂲";
          "on-click" = "blueman-manager";
          "on-click-right" = "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on";
        };

        network = {
          "format-wifi" = "<small>{bandwidthUpBytes}↑ {bandwidthDownBytes}↓</small>  {signalStrength}%";
          "format-ethernet" = " {ipaddr}/{cidr}";
          "format-disconnected" = "󰤭 Disconnected";
          "format-linked" = " {ifname} (No IP)";
          "tooltip-format" = "{essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}";
          "on-click" = "~/.config/waybar/scripts/network/rofi-network-manager.sh";
          "on-click-right" = "nm-connection-editor";
          interval = 5;
        };

        tray = {
          "icon-size" = 16;
          spacing = 8;
          "show-passive-items" = true;
        };

        clock = {
          timezone = "Europe/Tallinn";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%a, %d %b  %H:%M}";
          "format-alt" = "{:%Y-%m-%d %H:%M:%S}";
          interval = 1;
          "on-click" = "gnome-calendar";
        };

        cpu = {
          interval = 10;
          format = " {usage}%";
          max-length = 10;
          on-click = "alacritty -e sh -c 'htop -s PERCENT_CPU'";
        };

        memory = {
          interval = 5;
          format = " {percentage}%";
          format-alt = " {used:0.1f}GB";
          states = {
            warning = 70;
            critical = 90;
          };
          "on-click" = "alacritty -e sh -c 'htop -s PERCENT_MEM'";
        };

        disk = {
          interval = 30;
          format = "󰋊 {percentage_used}%";
          "format-alt" = "󰋊 {used}/{total}";
          path = "/";
        };

        mpris = {
          format = "{player_icon} {title}";
          "format-paused" = "{player_icon} {title}";
          "player-icons" = {
            default = "▶";
            mpv = "🎵";
            spotify = "";
            firefox = "";
          };
          "status-icons" = {
            paused = "⏸";
          };
          "max-length" = 40;
          "tooltip-format" = "{player_icon} {title}\nby {artist}\non {album}";
        };

        temperature = {
          thermal-zone = 2;
          format = " {temperatureC}°";
          critical-threshold = 70;
          format-critical = " {temperatureC}°";
          tooltip = true;
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon}";
          "format-icons" = [ "" "" "" ];
          tooltip = true;
          "tooltip-format" = "{percent}%";
          "on-scroll-up" = "brightnessctl set +5%";
          "on-scroll-down" = "brightnessctl set 5%-";
        };

        battery = {
          bat = "BAT0";
          adapter = "ADP0";
          interval = 60;
          states = {
            warning = 19;
            critical = 9;
          };
          format = "{icon}";
          "format-full" = "󰂄";
          "format-charging" = "<span font-family='Font Awesome 6 Free'></span>";
          "format-plugged" = "󰚥";
          "format-warning" = "{icon}";
          "format-critical" = "{icon}";
          "format-notcharging" = "󰚥";
          "format-alt" = "{icon}<small> {time}</small>";
          "format-icons" = [ "󱊡" "󱊢" "󱊣" ];
          "tooltip-format" = "{timeTo}\nPower draw: {power}W";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          "format-bluetooth" = " {icon} {volume}%";
          "format-muted" = "";
          "format-icons" = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            default = [ "" "" ];
          };
          tooltip = true;
          "tooltip-format" = "{volume}%";
          "scroll-step" = 5.0;
          "on-click" = "pavucontrol";
          "on-click-right" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        "sway/language" = {
          "format" = "{flag}";
          "min-length" = 3;
          "tooltip" = true;
          "tooltip-format" = "{long}";
        };

        "custom/launcher" = {
          format = "󱄅";
          "on-click" = "rofi -show drun &";
          tooltip = false;
        };

        "custom/cf-zt" = {
          format = "{icon}";
          "format-icons" = {
            default = [ "" ];
          };
          tooltip = true;
        };

        "custom/power-menu" = {
          format = "⏻";
          on-click = "wlogout";
          tooltip = false;
        };
      };
    };
  };
}
