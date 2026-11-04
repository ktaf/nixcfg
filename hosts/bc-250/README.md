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
* Governor software thermal throttling is disabled; firmware thermal limits are unchanged.
* `gpu-usage.temp-read = "sysfs"` reads the GPU temperature from hwmon `temp1_input` instead of keeping a DRM handle open.
  It is the same sensor. Without the DRM handle, gamescope session handovers are faster
  ([measured](https://github.com/MastaG/linux-cachyos-bc250#cyan-skillfish-governor-recommendations) at 0.09 s instead of 4.4 s).
  The governor logs `temperature read: sysfs` at startup.
* D-Bus support enables the packaged `cyan-skillfish-performance-mode` helper.
* The service includes `util-linux` in its command path for the GPU metrics bind mount.

A 2050 MHz point is commented out. Two 20-second vkmark blur runs gained about 1.5–2.2% over their paired 2000 MHz baselines,
but cooldown freezes occurred during testing.

### Clock response in games

Safe-points only set the voltage curve; they are not clock steps. The clock is chosen by the load loop.
One loop pass takes about 130 ms (65 busy-flag samples at 2 ms). Each step is `ramp-rates.normal` × 20 ms.

| Setting | Default / before | Now | Effect |
|---|---|---|---|
| `load-target.upper` | 0.95 | 0.85 | Clock rises when the GPU is busy more than 85% of the time, leaving frame-time headroom |
| `load-target.lower` | 0.7 | 0.65 | Clock may fall when the GPU is busy less than 65% of the time |
| `timing.ramp-rates.normal` | 1 (20 MHz/step, ~150 MHz/s) | 5 (100 MHz/step, ~770 MHz/s) | 1000 → 2000 MHz in about 1.3 s instead of about 7 s |
| `timing.down-events` | 10 (~1.3 s) | 30 (~4 s) | Short dips (loading, cutscenes) no longer drop the clock |
| `timing.burst-samples` | 48 (96 ms) | 32 (64 ms) | Continuous GPU work jumps to 2000 MHz sooner |

Idle and Steam menus still drop to 350 MHz after about 4 s of low load. Games spend more time at high clocks, so expect more heat.

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

Normal boot applies the unlock before user sessions and the GPU governor start, without boot-menu interaction.
Build the configuration, then reboot:

```bash
sudo nixos-rebuild boot --flake .#bc-250
sudo reboot
```

The `24cu` boot specialisation disables the unlock service and restores the stock layout after reboot.
For headless recovery, select its installed entry ID with `sudo bootctl set-oneshot ENTRY-ID` before rebooting.
Use `bootctl list --no-pager` to find the entry marked `NixOS (24cu)` for the intended generation.

Inspect the routing and test the command plan without changing it:

```bash
sudo bc250-cu-live-manager status
sudo bc250-cu-live-manager --dry-run enable all
```

For a manual runtime trial from a `24cu` boot, run `sudo bc250-cu-live-manager enable all` and review the tool's prompts.
This applies the registers immediately and does not save a boot service.

After rebooting into the normal entry:

```bash
systemctl status bc250-40cu-unlock.service --no-pager
sudo bc250-cu-live-manager status
```

This updates live hardware dispatch. The driver's cached CU count and Vulkan reports may still show 24 CUs.
A readback of the routing masks alone does not prove performance gains or CU correctness; compare the same workload before and after.
GPU resets may clear the live register settings. The boot service does not watch for resets.

The 2000 MHz / 1000 mV ceiling and disabled governor throttling are unchanged.
Our previous 24-CU test reached 85°C at 2000 MHz. The [original project's results](https://github.com/duggasco/bc250-40cu-unlock)
show higher power and temperature with 40 CUs and recommend starting at 1500 MHz / 900 mV.
This profile has not been hardware-tested here.

Build just the tool with `nix build .#bc250-cu-live-manager`.
Do not use its imperative `install-service` command on NixOS; [cu-unlock.nix](cu-unlock.nix) manages the boot service.

### Patched-driver alternative

[duggasco's patch](https://github.com/duggasco/bc250-40cu-unlock) applies during driver enumeration, so the driver can also report all 40 CUs.
It requires rebuilding `amdgpu` for each kernel ABI, but does not require rebuilding the rest of the kernel.
The original installer writes to `/lib/modules` and is not suitable for the Nix store.

A full custom kernel can also be exposed as a flake package and selected with `linuxPackagesFor`.
Neither a custom kernel nor a module package is automatically published to `cache.nixos.org`.
For prebuilt updates, a builder or CI must build each pinned revision and publish its closure to a configured Nix binary cache.
Clients then download matching cached outputs during rebuilds. Cache misses still require a build somewhere.

## ACPI tables

The P3.00 firmware has two CPU power-management bugs. [tuning.nix](tuning.nix) fixes both with initrd ACPI table overrides
from [ktaf/bc250-acpi-fix](https://github.com/ktaf/bc250-acpi-fix), a fork of the community repo. Both tables are compiled from source with `iasl` at a pinned commit.

* **No P-states.** The firmware ships no usable `_PSS`. `SSDT-PST` adds 8 P-states for `acpi-cpufreq`.
* **No deep C-states.** The firmware "AMD CPU" SSDT puts `_CST` on `\_PR.C000..C00B`, but the DSDT names the CPUs `\_PR.P000..P00B`.
  The table fails to load with 12 `AE_NOT_FOUND` errors, so cores never enter CC6.
  `SSDT-CST` is the same table with the scopes renamed and the OEM revision raised to 2, so the kernel replaces the firmware table.
  The fork's README explains why the upstream `SSDT-CST` was replaced.

To update, push to the fork, then change `rev` and `hash` in [tuning.nix](tuning.nix).

After the fix, idle Steam UI dropped from 36–62 W / 69–71 °C to 32–37 W / 60 °C Tctl (24-CU boot, one sample each, not a controlled test).
Single-core boost still reaches about 3.5 GHz.
With 40 CUs, the SMU governor, vkmark `effect2d` and 40% load on all 12 threads, CC6 on and off measured the same:
about 140 W PPT and the same vkmark score. Both runs reached 95 °C Tctl within 50 seconds.

Check the running system:

```bash
sudo dmesg | grep -E "Table Upgrade|AE_NOT_FOUND"   # expect "override [SSDT- AMD- AMD CPU]", no AE_NOT_FOUND
cat /sys/devices/system/cpu/cpuidle/current_driver  # acpi_idle
grep . /sys/devices/system/cpu/cpu0/cpuidle/state*/{name,desc,usage}  # C2 = ACPI IOPORT 0x414 (CC6)
```

If CC6 causes instability, add `processor.max_cstate=1` to `boot.kernelParams` to keep C1 only.

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

## Sleep

ACPI suspend on this board does not resume; the board needs a power cycle.
[tuning.nix](tuning.nix) sets `AllowSuspend`, `AllowHibernation`, `AllowHybridSleep` and `AllowSuspendThenHibernate` to `no`,
so logind refuses sleep from Steam's Sleep button, the power key or idle instead of hanging the board.

```bash
systemctl suspend   # expect an error: Sleep verb "suspend" is not supported
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
