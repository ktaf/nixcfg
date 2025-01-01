{ pkgs
, config
, ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.hyprland;

    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    xwayland.enable = true;

    # Automatically start essential applications
    extraConfig = ''
      # Essential startup applications
      # exec-once = swww init # Wallpaper daemon
      exec-once = hyprpaper # Wallpaper daemon
      exec-once = nm-applet --indicator # Network Manager applet
      # exec-once = warp-taskbar # Network Manager applet
      exec-once = hypridle # Idle daemon
      exec-once = wl-paste --type text --watch cliphist store # Clipboard history
      exec-once = wl-paste --type image --watch cliphist store # Image clipboard history
    '';

    settings = {
      monitor = [
        "eDP-1, preferred, 3440x240, 1"
        "desc:Dell Inc. DELL S3422DWG FSF4KK3, 3440x1440@120, 0x0, 1"
        "desc: Dell Inc. DELL S3423DWC C74VNH3,3440x1440@120, 0x0, 1"
        ",preferred,auto,1" # Fallback for any other monitors
      ];

      general = {
        gaps_in = 2;
        gaps_out = 2;
        layout = "dwindle";
        resize_on_border = true;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        # cursor_inactive_timeout = 4;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        no_gaps_when_only = true;
        force_split = 2;
        special_scale_factor = 0.8;
      };

      master = {
        # new_is_master = true;
        new_on_top = true;
      };

      input = {
        kb_layout = "us,ir";
        kb_variant = "qwerty";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          drag_lock = true;
          tap-to-click = true;
          middle_button_emulation = true;
        };
        sensitivity = 0;
        accel_profile = "flat";
        float_switch_override_focus = 2;
      };

      misc = {
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        always_follow_on_dnd = true;
        enable_swallow = true;
        swallow_regex = "^(kitty|alacritty|wezterm)$";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_invert = false;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_use_r = true;
      };

      binds = {
        allow_workspace_cycles = true;
        workspace_back_and_forth = true;
        # focus_preferred_method = "smart";
      };

      # Key bindings
      bind =
        let
          modifier = "Super";
          terminal = "alacritty";
          menu = "rofi -show";
          file_explorer = "nemo";
          lock_screen = "systemctl suspend && swaylock";
          screenshot_dir = "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d)";
        in
        [
          # System controls
          "CTRL ALT, Delete, exec, pkill Hyprland"
          "${modifier} ALT, R, exec, hyprctl reload"

          # Essential bindings
          "${modifier}, Tab, cyclenext"
          "${modifier}, Return, exec, ${terminal}"
          "${modifier}, R, exec, ${menu}"
          # "${modifier}, Space, exec, ${menu}"
          "${modifier}, E, exec, ${file_explorer}"
          "${modifier}, L, exec, ${lock_screen}"
          "${modifier}, F, fullscreen"
          "${modifier}, W, togglegroup"
          "${modifier}, P, pseudo"
          "${modifier}, T, togglesplit"
          "${modifier}, S, swapsplit"

          # SwayNC controls
          "${modifier}, N, exec, swaync-client -t -sw" # Toggle notification center

          # Window management
          "${modifier} Shift, Q, killactive"
          "${modifier} Shift, Space, togglefloating"
          "${modifier} Shift, P, pin"
          "${modifier} Shift, F, workspaceopt, allfloat"

          # Focus movement
          "${modifier}, left, movefocus, l"
          "${modifier}, right, movefocus, r"
          "${modifier}, up, movefocus, u"
          "${modifier}, down, movefocus, d"
          "${modifier}, h, movefocus, l"
          "${modifier}, l, movefocus, r"
          "${modifier}, k, movefocus, u"
          "${modifier}, j, movefocus, d"

          # Workspace management
          "${modifier}, 1, workspace, 1"
          "${modifier}, 2, workspace, 2"
          "${modifier}, 3, workspace, 3"
          "${modifier}, 4, workspace, 4"
          "${modifier}, 5, workspace, 5"
          "${modifier}, 6, workspace, 6"
          "${modifier}, 7, workspace, 7"
          "${modifier}, 8, workspace, 8"
          "${modifier}, 9, workspace, 9"
          "${modifier}, 0, workspace, 10"

          # Move windows to workspaces
          "${modifier} Shift, 1, movetoworkspace, 1"
          "${modifier} Shift, 2, movetoworkspace, 2"
          "${modifier} Shift, 3, movetoworkspace, 3"
          "${modifier} Shift, 4, movetoworkspace, 4"
          "${modifier} Shift, 5, movetoworkspace, 5"
          "${modifier} Shift, 6, movetoworkspace, 6"
          "${modifier} Shift, 7, movetoworkspace, 7"
          "${modifier} Shift, 8, movetoworkspace, 8"
          "${modifier} Shift, 9, movetoworkspace, 9"
          "${modifier} Shift, 0, movetoworkspace, 10"

          # Window resizing
          "${modifier} Control, left, resizeactive, -20 0"
          "${modifier} Control, right, resizeactive, 20 0"
          "${modifier} Control, up, resizeactive, 0 -20"
          "${modifier} Control, down, resizeactive, 0 20"

          # Screenshot bindings
          ", Print, exec, mkdir -p ${screenshot_dir} && grim ${screenshot_dir}/$(date +'%H-%M-%S').png"
          "Shift, Print, exec, mkdir -p ${screenshot_dir} && grim -g \"$(slurp)\" ${screenshot_dir}/$(date +'%H-%M-%S').png"
          "${modifier}, Print, exec, mkdir -p ${screenshot_dir} && grim -g \"$(slurp)\" - | wl-copy"

          # Clipboard manager
          "${modifier}, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        ];

      # Mouse bindings
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
        "SUPER ALT, mouse:272, resizewindow"
      ];

      # Hold bindings (for volume and brightness)
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # Toggle bindings
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      decoration = {
        drop_shadow = true;
        shadow_range = 1;
        shadow_render_power = 4;
        "col.shadow" = "rgba(00000044)";
        shadow_offset = "1 1";
        shadow_scale = 0.1;
        dim_inactive = true;
        dim_strength = 0.1;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
          special = true;
          xray = true;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
          "linear, 0.0, 0.0, 1.0, 1.0"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];

        animation = [
          "windows, 1, 5, myBezier, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "windowsMove, 1, 4, smoothIn"
          "border, 1, 10, linear"
          "borderangle, 1, 100, linear, loop"
          "fade, 1, 4, smoothIn"
          "workspaces, 1, 4, smoothIn, slidevert"
        ];
      };

      windowrulev2 = [
        # System apps
        "float,class:^(pavucontrol)$"
        "float,class:^(Bluetooth Devices)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(galculator)$"
        "float,title:^(Picture-in-Picture)$"
        "float,class:^(org.gnome.Calculator)$"
        "float,title:^(Media viewer)$"
        "float,title:^(Volume Control)$"
        "float,title:^(Picture in picture)$"
        "float,title:^(Open Files))$"
        # "float,title:^(Visual Studio Code)$"

        # SwayNC specific rules
        "float,class:^(swaync-control-center)$"
        "move 100%-400 0,class:^(swaync-control-center)$"
        "float,class:^(swaync-notification-window)$"
        "move 100%-400 0,class:^(swaync-notification-window)$"

        # Other rules
        "idleinhibit focus,class:^(mpv|.+exe)$"
        "idleinhibit fullscreen,class:^(firefox)$"
        "center,class:^(pavucontrol|galculator)$"
      ];
    };
  };
}
