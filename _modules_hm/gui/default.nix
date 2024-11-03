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
    slurp
    wdisplays
    wlr-randr
    wayland
    wayland-protocols
    wayland-scanner
    wayland-utils
    egl-wayland
    glfw-wayland
    mesa
    wlogout
    xcur2png

    ## SWAY
    autotiling
    swww
    # swaybg
    # swaycons
    # swayidle
    # swaylock-effects
    # swaysome

    pango
    file
    libglvnd
    libwebp

    brightnessctl
    pavucontrol
    playerctl
    cliphist
    wl-clipboard
    wf-recorder

    meson
    cairo

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

    qt6ct
    yad
  ];
}
