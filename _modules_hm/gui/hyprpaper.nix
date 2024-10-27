{ ... }: {

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "/home/kourosh/nixcfg/extras/wallpapers/wallpaper.png" "/home/kourosh/nixcfg/extras/wallpapers/background.jpg" ];

      wallpaper = [
        ", /home/kourosh/nixcfg/extras/wallpapers/wallpaper.png"
        ", /home/kourosh/nixcfg/extras/wallpapers/background.jpg"
      ];
    };
  };
}



