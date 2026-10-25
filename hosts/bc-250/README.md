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
* The configured frequency/voltage points are 350 MHz at 700 mV, 2000 MHz at 1000 mV, and 2050 MHz at 1000 mV.
* Governor software thermal throttling is disabled; firmware thermal limits are unchanged.
* D-Bus support enables the packaged `cyan-skillfish-performance-mode` helper.
* The service includes `util-linux` in its command path for the GPU metrics bind mount.

The 2050 MHz ceiling is experimental. Two 20-second vkmark blur runs gained about 1.5–2.2% over their paired 2000 MHz baselines.
Cooldown freezes occurred during testing, so sustained stability is not established.

For governor v0.4.14, `temperature.throttling = false` disables the software limiter through the parser's non-integer fallback.
It logs a type warning and uses no threshold. Omitting the setting restores the default 85°C threshold; `0` means 0°C.

Change the governor settings in `tuning.nix`, then rebuild:

```bash
sudo nixos-rebuild switch --flake .#bc-250
```

Check the service and logs:

```bash
systemctl --no-pager --full status cyan-skillfish-governor-smu.service
journalctl -u cyan-skillfish-governor-smu.service -b --no-pager
```

## 40-CU runtime unlock

The `bc250-cu-live-manager` package uses [WinnieLV's UMR workflow](https://github.com/WinnieLV/bc250-cu-live-manager)
to clear the harvest mask and enable all WGP dispatch registers. It uses the stock NixOS kernel and requires no kernel recompilation.
The source is pinned to a commit and hash in [the package](../../pkgs/bc250-cu-live-manager.nix).

Normal boot does not apply the unlock. The `40cu` boot specialisation applies it before user sessions and the GPU governor start.
Track the new Nix files, build the configuration, then reboot and choose its `40cu` entry:

```bash
git add pkgs/bc250-cu-live-manager.nix hosts/bc-250/cu-unlock.nix
sudo nixos-rebuild boot --flake .#bc-250
```

Boot the normal entry to restore the stock driver layout.

Inspect the routing and test the command plan without changing it:

```bash
sudo bc250-cu-live-manager status
sudo bc250-cu-live-manager --dry-run enable all
```

For a manual runtime trial from normal boot, run `sudo bc250-cu-live-manager enable all` and review the tool's prompts.
This applies the registers immediately and does not save a boot service.

After choosing the `40cu` boot entry:

```bash
systemctl status bc250-40cu-unlock.service --no-pager
sudo bc250-cu-live-manager status
```

This updates live hardware dispatch. The driver's cached CU count and Vulkan reports may still show 24 CUs.
A readback of the routing masks alone does not prove performance gains or CU correctness; compare the same workload before and after.
GPU resets may clear the live register settings. The boot service does not watch for resets.

The current 2050 MHz / 1000 mV curve and disabled governor throttling are unchanged.
Our previous 24-CU test reached 85°C at 2000 MHz. The [original project's results](https://github.com/duggasco/bc250-40cu-unlock)
show higher power and temperature with 40 CUs and recommend starting at 1500 MHz / 900 mV.
This profile has not been hardware-tested here.

Build just the tool with `nix build .#bc250-cu-live-manager`.
Do not use its imperative `install-service` command on NixOS; the specialisation manages the boot service.

### Patched-driver alternative

[duggasco's patch](https://github.com/duggasco/bc250-40cu-unlock) applies during driver enumeration, so the driver can also report all 40 CUs.
It requires rebuilding `amdgpu` for each kernel ABI, but does not require rebuilding the rest of the kernel.
The original installer writes to `/lib/modules` and is not suitable for the Nix store.

A full custom kernel can also be exposed as a flake package and selected with `linuxPackagesFor`.
Neither a custom kernel nor a module package is automatically published to `cache.nixos.org`.
For prebuilt updates, a builder or CI must build each pinned revision and publish its closure to a configured Nix binary cache.
Clients then download matching cached outputs during rebuilds. Cache misses still require a build somewhere.

## Storage and memory

* Root uses Btrfs with `compress=zstd:3`, `noatime`, and SSD options. `/boot` uses FAT without compression.
* Zram swap is enabled with a logical capacity of 50% of kernel-visible RAM. Its physical RAM use grows with stored data.
* The pinned NixOS configuration selects `zstd` for zram. No disk swap or zram writeback device is configured.
* `vm.swappiness = 180` favors compressed swap relative to reclaiming filesystem cache; it is not a percentage of RAM to swap.
* SSD TRIM runs weekly. Automatic Btrfs scrubbing is not enabled.

Check the running system:

```bash
findmnt -no FSTYPE,OPTIONS /
zramctl
swapon --show
free -h
sysctl vm.swappiness vm.page-cluster vm.watermark_boost_factor vm.watermark_scale_factor
systemctl status fstrim.timer --no-pager
```

In `zramctl`, `DATA` is the uncompressed data size, `COMPR` is its compressed size, and `TOTAL` includes RAM overhead.
Filesystem mount options describe the compression policy, not the compression ratio of existing files.

## Removing a previous Decky installation

Decky is no longer configured. Rebuild to remove its service, then disable CEF Remote Debugging in Steam's Developer settings.
Remove the marker created by the previous configuration as the Steam user, then restart the Steam session:

```bash
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/Steam/.cef-enable-remote-debugging"
systemctl --user restart steam-gamescope.service
```

Saved plugins and settings in `/var/lib/decky-loader` are retained.

## Notes

* **BIOS of choice:** P3 Modded version
* Kernel parameters and firmware choices matter on this device — keep it lean
* This setup assumes you want performance *only when gaming*, not permanently maxed clocks

## Reference

Excellent low‑level documentation for the BC‑250 lives here:

[https://elektricm.github.io/amd-bc250-docs](https://elektricm.github.io/amd-bc250-docs)

---

If you’re treating the BC‑250 like a tiny console rather than a desktop PC, this repo is opinionated in your favor.
