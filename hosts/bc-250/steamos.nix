{ pkgs, user, ... }: {

  environment.systemPackages = with pkgs; [
    # Gaming diagnostics
    mesa
    mesa-demos
    vulkan-loader
    vulkan-tools
    libGL
    libGLU
    radeontop

    # Steam
    mangohud

    # Libs
    keyutils
  ];

  environment.sessionVariables = {
    # Force RADV driver (not AMDVLK)
    AMD_VULKAN_ICD = "RADV";
    # Fix some graphical glitches
    RADV_DEBUG = "nohiz";

    # Disable compute queue (may not be needed on Mesa 25.1+)
    # RADV_DEBUG=nocompute

    # Use Zink (OpenGL over Vulkan) for better performance
    MESA_LOADER_DRIVER_OVERRIDE = "zink";

    MANGOHUD = "0";
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
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "2s";
      StandardOutput = "journal";
      StandardError = "journal";
      ExecStart = "${pkgs.gamescope}/bin/gamescope -f -- ${pkgs.steam}/bin/steam -gamepadui";
    };
  };

  hardware = {
    amdgpu = {
      initrd.enable = true;
      overdrive.enable = true;
    };
    xone.enable = true; # XBOX Drives
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
