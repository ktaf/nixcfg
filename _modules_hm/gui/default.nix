{ pkgs, ... }:
{

  imports = [
    # ./hypr
    ./gtk.nix
    ./kanshi.nix
    ./rofi.nix
    ./waybar.nix
    ./swaync.nix
    ./sway.nix
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = {
      sway = {
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
      };
    };
  };

  xdg.configFile."systemd/user/xdg-desktop-portal-wlr.service".source =
    "${pkgs.xdg-desktop-portal-wlr}/share/systemd/user/xdg-desktop-portal-wlr.service";

  xdg.dataFile = {
    "dbus-1/services/org.freedesktop.impl.portal.desktop.wlr.service".source =
      "${pkgs.xdg-desktop-portal-wlr}/share/dbus-1/services/org.freedesktop.impl.portal.desktop.wlr.service";
    "xdg-desktop-portal/portals/wlr.portal".source =
      "${pkgs.xdg-desktop-portal-wlr}/share/xdg-desktop-portal/portals/wlr.portal";
  };

  home.packages = with pkgs; [
    gtk4
    grim
    nordic
    papirus-icon-theme
    adwaita-icon-theme # Fallback icons
    hicolor-icon-theme # Base icon theme
    slurp
    wdisplays
    wlr-randr
    wayland
    wayland-protocols
    wayland-scanner
    wayland-utils
    egl-wayland
    glfw
    mesa
    mesa-gl-headers
    libdrm
    libgbm
    libglvnd
    lcms
    wlogout
    xcur2png

    ## SWAY
    autotiling
    awww

    pango
    file
    libwebp

    brightnessctl
    pavucontrol
    playerctl
    cliphist
    wl-clipboard

    meson

    xdg-user-dirs
    xdg-utils
    xdg-dbus-proxy
    xdg-desktop-portal-wlr
    xdg-desktop-portal
    xdg-desktop-portal-gtk

    gvfs
    imagemagick
    nwg-look
    libsForQt5.qt5ct

    qt6Packages.qt6ct
    yad
  ];
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
    ICON_THEME = "Papirus-Dark";
  };
}
