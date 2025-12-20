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
    swww

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
