{ pkgs, ... }:
{

  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    # ./hyprlock.nix
    ./gtk.nix
    ./kanshi.nix
    ./rofi.nix
    ./waybar.nix
    ./swaync.nix
    # ./swaylock.nix
  ];

  home.packages = with pkgs; [
    gnome-themes-extra
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


    pango
    file
    libglvnd
    libwebp
    hyprlang
    hyprutils
    hyprwayland-scanner

    brightnessctl
    pavucontrol
    playerctl
    cliphist
    wl-clipboard

    meson
    cairo

    xdg-user-dirs
    xdg-utils
    xdg-dbus-proxy
    xdg-desktop-portal-hyprland
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
