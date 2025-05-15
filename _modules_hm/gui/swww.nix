{ pkgs, ... }:
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
      ExecPostStart = "${pkgs.swww}/bin/swww img ~/nixcfg/extras/wallpapers/mario-home.gif";
      Restart = "on-failure";
      RestartSec = 3;
      TimeoutStartSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
