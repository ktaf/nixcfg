{ pkgs, user, ... }: {

  # Minimal fonts for Steam+Proton
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment = {
    systemPackages = with pkgs; [
      # Gaming diagnostics
      mesa
      mesa-demos
      vulkan-loader
      vulkan-tools
      libGL
      libGLU
      nvtopPackages.amd

      # Steam
      mangohud

      # Libs
      keyutils
    ];

    sessionVariables = {
      # Force RADV driver (not AMDVLK)
      AMD_VULKAN_ICD = "RADV";

      # On-disk cache under ~/.cache; default is 1G, which re-stutters on replay.
      MESA_SHADER_CACHE_MAX_SIZE = "32G";

      # # Use Zink (OpenGL over Vulkan) for better performance
      # MESA_LOADER_DRIVER_OVERRIDE = "zink";
    };
  };

  # Controllers / input
  hardware.uinput.enable = true;
  services.udev.packages = with pkgs; [ game-devices-udev-rules ];

  # Audio (Steam/Proton friendly)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # Steam + Gamescope: boot straight into Steam Big Picture without a DM
  programs = {
    steam = {
      enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    gamemode.enable = true;
  };

  # No display manager: autologin on tty1
  services.getty.autologinUser = user;

  systemd.user.services.steam-gamescope = {
    description = "Steam in Gamescope (TTY1)";
    wantedBy = [ "default.target" ];
    path = [ "/run/wrappers" "/run/current-system/sw" pkgs.mangohud pkgs.gamescope ];
    environment.MANGOHUD_CONFIG = "preset=2";
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "2s";
      StandardOutput = "journal";
      StandardError = "journal";
      # The /run/wrappers capability wrapper passes cap_sys_nice via AMBIENT caps,
      # which every descendant inherits — and Steam's bubblewrap sandbox refuses to
      # run with unexpected capabilities (instant, silent exit). setpriv strips the
      # ambient/inheritable sets for the Steam side only; gamescope keeps its RT cap.
      ExecStart = "/run/wrappers/bin/gamescope -e -f --mangoapp -- ${pkgs.util-linux}/bin/setpriv --ambient-caps -all --inh-caps -all ${pkgs.steam}/bin/steam -gamepadui";
    };
  };

  # GPU Governor on NixOS
  services.cyan-skillfish-governor = {
    enable = true;

    settings = {
      timing = {
        intervals = {
          # µs
          sample = 500;
          adjust = 200000;
        };
        ramp-rates = {
          # MHz/ms
          normal = 4;
          burst = 100; # idle → max in ~18 ms once burst triggers
        };
        burst-samples = 32;
      };
      # MHz
      frequency-thresholds.adjust = 10;

      load-target = {
        upper = 0.75;
        lower = 0.65;
      };
      # MHz / mV
      safe-points = [
        { frequency = 350; voltage = 700; }
        { frequency = 500; voltage = 700; }
        { frequency = 1175; voltage = 700; }
        { frequency = 1400; voltage = 750; }
        { frequency = 1600; voltage = 800; }
        { frequency = 1700; voltage = 850; }
        { frequency = 1850; voltage = 900; }
        { frequency = 2000; voltage = 950; }
        { frequency = 2050; voltage = 975; }
        { frequency = 2100; voltage = 1000; }
        { frequency = 2125; voltage = 1015; }
        { frequency = 2150; voltage = 1030; }
        { frequency = 2200; voltage = 1050; }
        { frequency = 2230; voltage = 1085; }
        { frequency = 2300; voltage = 1110; }
        { frequency = 2350; voltage = 1130; }
        # { frequency = 2400; voltage = 1150; } # docs: liquid cooling only
      ];
    };
  };
  
  hardware = {
    xone.enable = true; # XBOX Drivers
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
