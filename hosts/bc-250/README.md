# BC-250

NixOS implementation of a SteamOS‑like setup for the **ASRock AMD‑BC‑250** — tuned to boot fast, stay lean, and drop you straight into gaming mode.

This repo focuses on *control, reproducibility, and performance* rather than mimicking SteamOS bit‑for‑bit.

## Highlights

* SteamOS‑style console experience built on **pure NixOS**
* Boots directly into Steam / Gamescope
* Minimal background services, low idle overhead
* SMU GPU governor packaged in nixpkgs and configured through NixOS
* Jovian has been tested and works, but is noticeably heavier and laggier on this hardware

## GPU Governor

This host uses `cyan-skillfish-governor-smu` from nixpkgs. The previous custom flake has been retired.

* Upstream: [filippor/cyan-skillfish-governor](https://github.com/filippor/cyan-skillfish-governor)
* [configuration.nix](configuration.nix) installs the package.
* [tuning.nix](tuning.nix) generates `/etc/cyan-skillfish-governor-smu/config.toml` and starts the systemd service at boot.
* The configured frequency/voltage points are 350 MHz at 700 mV and 2000 MHz at 1000 mV.
* D-Bus support enables the packaged `cyan-skillfish-performance-mode` helper.
* The service includes `util-linux` in its command path for the GPU metrics bind mount.

Change the governor settings in `tuning.nix`, then rebuild:

```bash
sudo nixos-rebuild switch --flake .#bc-250
```

Check the service and logs:

```bash
systemctl --no-pager --full status cyan-skillfish-governor-smu.service
journalctl -u cyan-skillfish-governor-smu.service -b --no-pager
```

## Notes

* **BIOS of choice:** P3 Modded version
* Kernel parameters and firmware choices matter on this device — keep it lean
* This setup assumes you want performance *only when gaming*, not permanently maxed clocks

## Reference

Excellent low‑level documentation for the BC‑250 lives here:

[https://elektricm.github.io/amd-bc250-docs](https://elektricm.github.io/amd-bc250-docs)

---

If you’re treating the BC‑250 like a tiny console rather than a desktop PC, this repo is opinionated in your favor.
