{ config, pkgs, lib, ... }:

{
  services.syncthing = {
    enable = true;
    tray.enable = true; # Enable the tray icon

    # Configure Syncthing to start automatically
    extraOptions = [
      "autostart = true"
      "startBrowser = false" # Don't open browser on startup
    ];

    #     # Set up your devices and folders here
    #     settings = {
    #       gui = {
    #         theme = "dark";  # Use dark theme
    #         user = "your-username";
    #         password = "your-password-hash";  # Generate with 'syncthing generate-password-hash'
    #       };

    #       options = {
    #         globalAnnounceEnabled = true;
    #         localAnnounceEnabled = true;
    #         relaysEnabled = true;
    #         natEnabled = true;
    #         urAccepted = -1;  # Disable usage reporting
    #         startBrowser = false;
    #         maxConcurrentScans = 10;
    #       };

    #       devices = {
    #         "device-1" = {
    #           id = "your-device-id-1";
    #           name = "Device 1";
    #           addresses = [ "dynamic" ];
    #           introducer = false;
    #           autoAcceptFolders = false;
    #         };
    #         # Add more devices as needed
    #       };

    #       folders = {
    #         "documents" = {
    #           path = "~/Documents";
    #           devices = [ "device-1" ];
    #           rescanIntervalS = 3600;
    #           fsWatcherEnabled = true;
    #           type = "sendreceive";
    #           versioning = {
    #             type = "simple";
    #             params = {
    #               keep = "5";
    #             };
    #           };
    #         };
    #         # Add more folders as needed
    #       };
    #     };
    #   };

    #   # Ensure the tray icon works with your desktop environment
    #   home.packages = with pkgs; [
    #     syncthingtray  # GUI tray application
    #   ];

    #   # Systemd user service configuration
    #   systemd.user.services.syncthing = {
    #     Unit = {
    #       Description = "Syncthing - Open Source Continuous File Synchronization";
    #       After = [ "network.target" ];
    #     };
    #     Service = {
    #       ExecStart = "${pkgs.syncthing}/bin/syncthing";
    #       Restart = "on-failure";
    #       SuccessExitStatus = [ 3 4 ];
    #       RestartForceExitStatus = [ 3 4 ];
    #     };
    #     Install = {
    #       WantedBy = [ "default.target" ];
    #     };
  };
}
