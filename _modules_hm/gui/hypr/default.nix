{ pkgs, ... }:
{

  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    ./hypridle.nix
  ];

  home.packages = with pkgs; [
    hyprlang
    hyprutils
    hyprwayland-scanner
  ];
}
