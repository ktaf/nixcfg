{ ... }: {

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "${config.home.homeDirectory}/nixcfg/extras/wallpapers/wallpaper.png" "${config.home.homeDirectory}/nixcfg/extras/wallpapers/background.jpg" ];

      wallpaper = [
        ", ${config.home.homeDirectory}/nixcfg/extras/wallpapers/wallpaper.png"
        ", ${config.home.homeDirectory}/nixcfg/extras/wallpapers/background.jpg"
      ];
    };
  };
}



