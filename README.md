# NixOS

My own NixOS setup.

```bash
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

To apply the standalone Home Manager configuration:

```bash
home-manager switch --flake .#ktaf
```

All host configurations (defined in `flake.nix` under `nixosConfigurations`) can be built with:

```bash
nixos-rebuild build --flake .#<hostname>   # e.g. .#homie, .#arvanix, .#x1g12
```
