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
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config = {
      common = {
        default = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
      };
      sway = {
        default = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
      };
    };
  };

  xdg.configFile."systemd/user/xdg-desktop-portal-wlr.service".source =
    "${pkgs.xdg-desktop-portal-wlr}/share/systemd/user/xdg-desktop-portal-wlr.service";

  home.packages = with pkgs; [
    gtk4
    grim
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
