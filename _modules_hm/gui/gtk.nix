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
      name = "Hack Nerd 12";
      package = pkgs.hack-font;
    };
  };

  # QT
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "qtct";
  };
}
