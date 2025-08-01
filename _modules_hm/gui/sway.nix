{ pkgs, config, lib, ... }:
{
  # Add systemd service for swww daemon
  systemd.user.services.swww = {
    Unit = {
      Description = "Wallpaper daemon for Wayland";
      After = [ "graphical-session.target" ];
      Requires = [ "sway-session.target" ];
    };
    Service = {
      Type = "simple";
      Environment = "SWWW_TRANSITION_FPS=30"; # Lower FPS for better stability
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
      RestartSec = 3;
      TimeoutStartSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.sway;
    xwayland = true;

    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    config = {
      startup = [
        # Environment setup for screensharing IMORTANT!
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }

        { command = "gnome-keyring-daemon --start --components=secrets"; }

        # SystemD service is enabled in home.nix
        # # System tray applets
        { command = "nm-applet --indicator"; }
        # { command = "${pkgs.blueman}/bin/blueman-applet"; }

        # Autotiling
        { command = "${pkgs.autotiling}/bin/autotiling"; always = true; }

        # Auto monitor configuration
        { command = "systemctl --user restart kanshi.service"; always = true; }

        { command = "swww-daemon && swww img ~/nixcfg/extras/wallpapers/mario-home.gif"; }

        # Clipboard history & Image clipboard history
        {
          command = ''
            wl-paste --type text --watch cliphist store && \
            wl-paste --type image --watch cliphist store
          '';
        }

        # Applications
        { command = "google-chrome-stable --profile-directory=Default --disable-features=RegistrationDeprecation"; }
        { command = "google-chrome-stable --profile-directory='Profile 1' --disable-features=RegistrationDeprecation"; }
        { command = "slack"; }

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

      assigns = {
        "2" = [{ class = "^Kourosh$"; }];
        "3" = [{ class = "^Slack$"; } { class = "^Work$"; }];
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
          lock_screen = "swaylock -f";
          screenshot_dir = "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d)";
        in
        lib.mkOptionDefault {
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${modifier}+q" = "kill";
          "${modifier}+r" = "exec ${pkgs.rofi}/bin/rofi -show";
          "${modifier}+l" = "exec ${lock_screen}";
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

          # SwayNC controls
          "${modifier}+N" = "exec swaync-client -t -sw"; # Toggle notification center

          # Clipboard manager
          "${modifier}+Shift+V" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";

          # Screenshots
          "Print" = "exec mkdir -p ${screenshot_dir} && grim ${screenshot_dir}/$(date +'%H-%M-%S').png";
          "Shift+Print" = "exec mkdir -p ${screenshot_dir} && grim -g \"$(slurp)\" ${screenshot_dir}/$(date +'%H-%M-%S').png";
          "${modifier}+Print" = "exec mkdir -p ${screenshot_dir} && grim -g \"$(slurp)\" - | wl-copy";
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
            command = "max_render_time 1";
            criteria = { class = "^.*"; };
          }
          {
            command = "max_render_time 1";
            criteria = { app_id = "^.*"; };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "TelegramDesktop"; };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "Picture in picture"; };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "Meet"; };
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
            criteria = {
              title = "^Sign in*";
              window_type = "dialog";
            };
          }
          {
            command = "floating enable, sticky toggle";
            criteria = { title = "^Logige sisse*"; };
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
        command = "waybar";
        trayOutput = "*";
      }];
    };

    extraConfig = ''
      bindswitch --reload --locked lid:on output eDP-1 disable
      bindswitch --reload --locked lid:off output eDP-1 enable
      smart_borders on
      focus_follows_mouse always
    '';

    extraSessionCommands = ''
      # Graphics
      export WLR_DRM_NO_ATOMIC=1
      export WLR_NO_HARDWARE_CURSORS=1
      export __GLX_VENDOR_LIBRARY_NAME=mesa
      export GBM_BACKEND=intel
      export EGL_PLATFORM=wayland
      
      # Performance
      export VBLANK_MODE=0
      export __GL_SYNC_TO_VBLANK=0

      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=sway
    '';
  };
  # Optional: Create a shell script for easy wallpaper switching
  home.file.".local/bin/wallpaper-switch" = {
    executable = true;
    text = ''
      #!/bin/sh
      CURSOR_POS=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .rect | "\(.x + .width / 2),\(.y + .height / 2)"')
      
      ${pkgs.swww}/bin/swww img "$1" \
        --transition-type random \
        --transition-fps 60 \
        --transition-duration 2 \
        --transition-pos "$CURSOR_POS"
    '';
  };

  # Optional: Create a script for random wallpaper switching
  home.file.".local/bin/wallpaper-random" = {
    executable = true;
    text = ''
      #!/bin/sh
      WALLPAPERS_DIR="$HOME/nixcfg/extras/wallpapers"
      CURSOR_POS=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .rect | "\(.x + .width / 2),\(.y + .height / 2)"')
      
      RANDOM_WALL=$(find "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | shuf -n 1)
      
      ${pkgs.swww}/bin/swww img "$RANDOM_WALL" \
        --transition-type random \
        --transition-fps 60 \
        --transition-duration 2 \
        --transition-pos "$CURSOR_POS"
    '';
  };
}
