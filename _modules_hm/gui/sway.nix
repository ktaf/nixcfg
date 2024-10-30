{ pkgs
, config
, lib
, ...
}: {
  wayland.windowManager.sway = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.sway;
    xwayland = true;

    systemd = {
      enable = true;
    };

    config = {
      startup = [
        # Environment setup for screensharing IMORTANT!
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }

        # SystemD service is enabled in home.nix
        # # System tray applets
        # { command = "nm-applet --indicator"; }
        # { command = "${pkgs.blueman}/bin/blueman-applet"; }

        # Autotiling
        { command = "${pkgs.autotiling}/bin/autotiling"; always = true; }
        # Applications
        { command = "slack"; }
        { command = "telegram-desktop"; }
        # Screen locking
        {
          command = ''
            ${pkgs.swayidle}/bin/swayidle -w \
              timeout 300 'swaylock -f' \
              timeout 600 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
              before-sleep '${pkgs.playerctl}/bin/playerctl pause' \
              before-sleep 'swaylock -f'
          '';
        }
        # Auto monitor configuration
        { command = "pkill kanshi; ${pkgs.kanshi}/bin/kanshi"; always = true; }
      ];
      modifier = "Mod4"; #SUPER KEY
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.rofi}/bin/rofi -show";

      gaps = {
        inner = 2;
        outer = 2;
        smartGaps = true;
      };

      defaultWorkspace = "workspace number 1";

      workspaceOutputAssign = [
        { workspace = "1"; output = "eDP-1"; }
        { workspace = "2"; output = "DP-2 DP-6 eDP-1"; }
        { workspace = "3"; output = "DP-2 DP-6 eDP-1"; }
        { workspace = "4"; output = "DP-2 DP-6 eDP-1"; }
      ];

      assigns = {
        "3" = [{ class = "^Slack$"; }];
        "4" = [{ app_id = "^org.telegram.desktop$"; }];
      };

      input = {
        "*" = {
          xkb_layout = "us,ir";
          xkb_options = "grp:alt_shift_toggle";
          xkb_numlock = "enable";
        };
      };

      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${modifier}+q" = "kill";
          "${modifier}+r" = "exec ${pkgs.rofi}/bin/rofi -show";
          "${modifier}+l" = "exec swaylock -f";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" = "swaymsg exit";

          # Layout controls
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+f" = "fullscreen";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";

          # Workspace switching
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";

          # Move container to workspace
          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          # Screenshots
          # "Print" = "exec ${pkgs.grim}/bin/grim save active /home/$USER/screenshots/Screenshot-$(date -Iseconds | cut -d'+' -f1).png";
          # "${modifier}+Print" = "exec ${pkgs.grimshot}/bin/grimshot save area /home/$USER/screenshots/Screenshot-$(date -Iseconds | cut -d'+' -f1).png";
          # "${modifier}+Shift+Print" = "exec ${pkgs.wf-recorder}/bin/wf-recorder -a -o eDP-1 -f /home/$USER/screenshots/Screenstream-$(date -Iseconds | cut -d'+' -f1).mp4";

          # Media keys
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86Search" = "exec ${pkgs.rofi}/bin/rofi -show";
        };

      window = {
        titlebar = false;
        border = 2;
        commands = [
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "Picture-in-picture"; };
          }
          {
            command = "floating enable, resize set width 680 height 400, move position center";
            criteria = { app_id = "blueman-manager"; };
          }
          {
            command = "floating enable, resize set width 680 height 400, move position center";
            criteria = { app_id = "pavucontrol"; };
          }
          {
            command = "floating enable, move position center";
            criteria = { app_id = "nm-connection-editor"; };
          }
          {
            command = "floating enable, move center";
            criteria = { title = "Calculator"; };
          }
          {
            command = "resize set width 1020 height 260, move right";
            criteria = { app_id = "org.telegram.desktop"; };
          }
          {
            command = "move position right, resize set width 735 height 1036";
            criteria = { class = "Slack"; };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "File Operation Progress"; };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "Confirm to replace files"; };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "^.Sign in*"; };
          }
          {
            command = "inhibit_idle fullscreen";
            criteria = { class = "^.*"; };
          }
          {
            command = "inhibit_idle fullscreen";
            criteria = { app_id = "^.*"; };
          }
        ];
      };

      bars = [{
        command = "${pkgs.waybar}/bin/waybar";
      }];
    };

    extraConfig = ''
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
      focus_follows_mouse always
    '';

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
    '';

    extraOptions = [
      "--unsupported-gpu"
    ];
  };
}
