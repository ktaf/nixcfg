{ pkgs, ... }: {

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark"; # Case-Sensitive
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Hack Nerd Font 12";
      package = pkgs.hack-font;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-icon-theme-name = "Papirus-Dark";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-icon-theme-name = "Papirus-Dark";
    };
  };
  # QT
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "qtct";
  };
}
