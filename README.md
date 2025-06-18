# NixOS

My own NixOS setup.

```bash
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

To apply the Home Manager configuration:

```bash
home-manager switch --flake .#kourosh
```

Replace `<hostname>` with one of the hosts defined in `flake.nix` such as `homie`, `arvanix` or `x1g12`.
