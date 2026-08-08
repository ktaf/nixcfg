{ pkgs, inputs, user, ... }: {

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
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "2s";
      StandardOutput = "journal";
      StandardError = "journal";
      # --mangoapp with -e exports STEAM_USE_MANGOAPP/STEAM_MANGOAPP_PRESETS_SUPPORTED,
      # which is what puts the overlay control in the Steam QAM ("..." menu).
      ExecStart = "${pkgs.gamescope}/bin/gamescope -e -f --mangoapp -- ${pkgs.steam}/bin/steam -gamepadui";
    };
  };

  # GPU Governor on NixOS
  _module.args.self = inputs.cyan-skillfish-governor;
  services.cyan-skillfish-governor.enable = true;

  hardware = {
    xone.enable = true; # XBOX Drivers
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
