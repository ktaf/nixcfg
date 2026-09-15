# Walter

Named after Walter Bishop from *Fringe*. A **Lenovo ThinkCentre M80q Gen 3**
running the household media and photo stack — Plex, Immich, Sonarr/Radarr/Bazarr,
Prowlarr, Transmission and Samba.

i5-12500T (6C/12T, 35 W), Intel UHD 770, 2x8 GB DDR5-4800, I219-LM gigabit.
Four SSDs, no pooling or RAID — each is an independent btrfs filesystem mounted
`compress=zstd:3,ssd,space_cache=v2,noatime`.

## Storage

| Disk | Mount | Role |
| --- | --- | --- |
| Samsung MZALQ256 256 GB NVMe | `/` `/home` `/nix` `/boot` | OS |
| Kingston NV2 2 TB NVMe | `/data` | Current library, being retired |
| Crucial BX500 4 TB SATA | `/media` | Movies, series, downloads, public share |
| Crucial P5 Plus 1 TB NVMe | `/fast` | Immich library, Plex transcode scratch |

`/media` is deliberately flat — no subvolumes. Hardlinks cannot cross a subvolume
boundary, and Sonarr/Radarr rely on them between `downloads/complete` and the
library; splitting the two would silently turn every import into a full copy.


## Power

Idle: **1.63 W package, 99 % core C10, 99.97 % GFX RC6.** The core side is
effectively at its floor.

Package C-states stop at PC2, held there independently by two devices:

- **Kingston NV2** — `LnkCap: ASPM not supported`, so root port `00:1b.0` runs
  with ASPM and all L1 substates disabled.
- **Crucial BX500** — libata applies the `nolpm` quirk (`LPM support broken,
  forcing max_power`), and `link_power_management_policy` rejects every write
  with `EOPNOTSUPP`.

PC8/PC10 requires both to go, which an all-NVMe layout would be the only way to
achieve. Firmware also declares `FADT indicates ASPM is unsupported`, leaving
ASPM entirely to the BIOS and making `pcie_aspm.policy=` a no-op.

`tuning.nix` therefore carries only what measurably applies on this board:
`powersave` governor with `balance_power` EPP via udev, zstd zram at half of RAM
with `swappiness=100`/`page-cluster=0`, monthly scrubs and smartd. Async discard
is a kernel default on these mounts, so no `discard=` option and no fstrim timer.

## Configured outside Nix

State that lives in an application's own database rather than the Nix store:

- Plex — hardware transcoding toggle and library paths
- Immich — Quick Sync toggle in the admin UI
- Samba — `smbpasswd -a win`
