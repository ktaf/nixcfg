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

## Walter

Named after Walter Bishop from *Fringe*. Lenovo ThinkCentre M80q Gen 3,
i5-12500T (6 cores / 12 threads), Intel UHD 770, 16 GB RAM, gigabit Ethernet.

| Disk | Mount | Role |
| --- | --- | --- |
| Samsung 256 GB NVMe | `/`, `/home`, `/nix`, `/boot` | Existing OS; never provision with Disko |
| Kingston NV2 2 TB | `/data` | Existing downloads and public share; never provision with Disko |
| Crucial BX500 4 TB, serial `2522E9C1AC01` | `/media` | Movies, series and future downloads |
| Crucial P5 Plus 1 TB, serial `21303083DCC2` | `/fast` | Plex transcode scratch; reserved `apps` and `vms` directories |

`hosts/walter/storage.nix` declares only the two spare disks in Disko, by stable
hardware IDs. The filesystems remain independent: no striping or pooling.
Normal rebuilds never format disks. Initial provisioning, **only after verifying
both target disks are disposable and unmounted**, is:

```bash
nix build .#nixosConfigurations.walter.config.system.build.formatScript -o result-format
sudo ./result-format
sudo nixos-rebuild switch --flake .#walter
```

Track new source files with Git before using `.#walter`. The format script is
separate from activation; do not use Disko's destroy mode. Inspect the generated
script before running it. Both disks must be provisioned before switching.

### Efficiency and maintenance

- Intel `powersave` with `balance_power` favours efficiency while retaining turbo
  for short jobs. Thermald stays enabled. PCIe power saving respects advertised
  hardware support; SATA uses `med_power_with_dipm`. NVMe retains kernel APST defaults.
- ZSTD zram provides up to half of RAM in logical swap capacity, allocated on
  demand. It does not reserve 8 GB up front or replace physical RAM.
- OS and new disks use `compress=zstd:1`, `noatime`, and asynchronous discard.
  `/data` keeps its existing ZSTD level 3. Compression affects new writes;
  already compressed video gains little. No forced recompression or defragmentation.
- Monthly Btrfs scrubs, weekly TRIM and SMART monitoring are enabled. Scrubbing
  detects corrupt single-copy data but cannot repair it without another copy.
- Plex has Intel drivers, GPU access, hardware codec preferences, low-priority
  event-driven scans and `/fast/plex-transcode`. Preview thumbnail generation and
  automatic trash emptying are disabled. Preferences are applied at service start
  while preserving credentials and unrelated settings. Hardware transcoding needs
  Plex Pass; verify `(hw)` during actual playback. Prefer Direct Play.
- Samba uses the standard package with default socket tuning. Shares are
  `\\192.168.2.100\public` and `\\192.168.2.100\media`, using the existing `win`
  account. Its Samba password database is runtime secret state, not a Nix setting.
- The static `eno1` configuration replaces obsolete Dell NetworkManager profiles.
  Wake-on-LAN stays enabled. EEE was enabled but inactive because the switch did
  not advertise it. Keep MTU 1500; gigabit networking will cap large transfers
  before NVMe speed matters.

### Media migration and future workloads

Existing Transmission paths remain under `/data`. For the eventual migration,
keep completed torrents and the Sonarr/Radarr library on the **same filesystem**
under `/media`; separate subvolumes would also prevent hardlinks. Pause writers,
copy with `rsync -aHAX` (include all hardlinked trees in one invocation), verify
checksums, then update library roots and torrent locations. Keep the originals
until playback and seeding are verified. Copies between disks cannot preserve
Btrfs reflinks, so allow for expanded space use. Adding the new Plex library path
before removing the old one preserves the migration workflow.

Reserve `/fast` for latency-sensitive apps, databases or a few small VMs; move
state there only with a service-specific backup and migration. For Immich, Intel
Quick Sync transcoding and limited background job concurrency are the next
steps when imports grow. With 16 GB RAM, monitor memory pressure before adding
VMs or concurrent photo indexing; zram is a cushion. Keep irreplaceable photos,
databases and configuration backed up to another machine or offline disk.

Initial 2026-09-15 idle sample: CPU package 1.6–1.7 W, approximately 99% core C10,
but package mostly PC2. The Kingston NV2 reports no ASPM support and may limit
deeper package states. These are not wall-power measurements. Measure at the
socket under comparable idle/load conditions before claiming savings; every
continuous watt is 8.76 kWh/year. BIOS C-states/ASPM and switch EEE need hardware
support and cannot be guaranteed by this repo.

References: [Intel CPU power management](https://docs.kernel.org/admin-guide/pm/intel_pstate.html),
[Btrfs compression](https://btrfs.readthedocs.io/en/latest/Compression.html),
[Plex hardware transcoding](https://support.plex.tv/articles/115002178853-using-hardware-accelerated-streaming/),
[Immich hardware transcoding](https://docs.immich.app/features/hardware-transcoding/).
