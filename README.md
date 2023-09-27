# NixOS - SwayWM

My own NixOS setup.

Create this to try a new setup based on another Wayland compositor tiling window manager Sway WM, Idk if it was Hyprland itself or my the configuration but overall I felt like Hyprland is not stable yet! 


```
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
nix flake update
sudo nixos-rebuild switch --flake .#kourosh