# NixOS

My own NixOS setup.


```
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
nix flake update
sudo nixos-rebuild switch --flake .#kourosh