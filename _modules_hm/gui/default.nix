{ pkgs, ... }:
{

  imports = [
    ./hyprland.nix
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

    brightnessctl

    xdg-utils
    xdg-dbus-proxy
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-wlr
    xdg-desktop-portal
    xdg-desktop-portal-gtk
  ];
}
