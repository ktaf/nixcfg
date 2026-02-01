# BC-250

NixOS implementation of a SteamOS‑like setup for the **ASRock AMD‑BC‑250** — tuned to boot fast, stay lean, and drop you straight into gaming mode.

This repo focuses on *control, reproducibility, and performance* rather than mimicking SteamOS bit‑for‑bit.

## Highlights

* SteamOS‑style console experience built on **pure NixOS**
* Boots directly into Steam / Gamescope
* Minimal background services, low idle overhead
* **Custom GPU governor fully nixified** (see below)
* Jovian has been tested and works, but is noticeably heavier and laggier on this hardware

## GPU Governor (Nixified)

The GPU power/performance governor is no longer a WIP.

I **forked and fully nixified** the Cyan Skillfish governor and made it easy to consume from Nix flakes.

* Fork (NixOS-friendly): [https://github.com/ktaf/cyan-skillfish-governor](https://github.com/ktaf/cyan-skillfish-governor)
* Upstream project: [https://github.com/Magnap/cyan-skillfish-governor](https://github.com/Magnap/cyan-skillfish-governor)
* Original author: **Magnap**
* Works cleanly on NixOS
* Can be enabled declaratively
* Suitable for auto-switching profiles (idle vs gaming)

### Why this approach?

* No mutable scripts living outside the Nix store
* Reproducible behavior across rebuilds
* Easy to audit, tweak, or disable
* Designed to integrate nicely with GameMode / Gamescope workflows

## How to Use the GPU Governor on NixOS

### 1. Add it to your `flake.nix`

```nix
inputs = {
  cyan-skillfish-governor.url = "github:ktaf/cyan-skillfish-governor";
};
```

Then pass it through your outputs (example):

```nix
outputs = { self, nixpkgs, cyan-skillfish-governor, ... }:
{
  nixosConfigurations.bc-250 = nixpkgs.lib.nixosSystem {
    modules = [
      cyan-skillfish-governor.nixosModules.default
    ];
  };
};
```

### 2. Enable it in `configuration.nix`

```nix
_module.args.self = inputs.cyan-skillfish-governor;
services.cyan-skillfish-governor = {
  enable = true;
};
```

Rebuild and you’re done:

```bash
sudo nixos-rebuild switch --flake .#
```

The governor will now manage GPU clocks/power states according to the configured profile.

## Notes

* **BIOS of choice:** P3 Modded version
* Kernel parameters and firmware choices matter on this device — keep it lean
* This setup assumes you want performance *only when gaming*, not permanently maxed clocks

## Reference

Excellent low‑level documentation for the BC‑250 lives here:

[https://elektricm.github.io/amd-bc250-docs](https://elektricm.github.io/amd-bc250-docs)

---

If you’re treating the BC‑250 like a tiny console rather than a desktop PC, this repo is opinionated in your favor.
