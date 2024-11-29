{ pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    tray.enable = true; # Enable the tray icon

    # Configure Syncthing to start automatically
    extraOptions = [
      "autostart = true"
      "startBrowser = false" # Don't open browser on startup
    ];
  };
}
