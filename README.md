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

Lenovo ThinkCentre M80q Gen 3. i5-12500T, UHD 770, 2x8 GB DDR5-4800, I219-LM.

| Disk | Mount | Role |
| --- | --- | --- |
| Samsung MZALQ256 256 GB | `/` `/home` `/nix` `/boot` | OS |
| Kingston NV2 2 TB | `/data` | Current library, 84 % full |
| Crucial BX500 4 TB SATA | `/media` | Movies, series, downloads, public share |
| Crucial P5 Plus 1 TB | `/fast` | Immich library, Plex transcode |

`/media` is flat on purpose so Sonarr/Radarr hardlinks work between
`downloads/complete` and the library. The spare disks were made with:

```bash
printf 'label: gpt\nstart=1MiB, type=linux, name=media\n' | sudo sfdisk /dev/sda
printf 'label: gpt\nstart=1MiB, type=linux, name=fast\n'  | sudo sfdisk /dev/nvme0n1
sudo mkfs.btrfs -L media /dev/sda1
sudo mkfs.btrfs -L fast  /dev/nvme0n1p1
```

### Retiring the Kingston

`media.nix` derives service paths from `bulk`, `library` and `scratch`. Copy in
one rsync so cross-tree hardlinks survive, then set `bulk = "/media"`:

```bash
sudo systemctl stop transmission sonarr radarr bazarr plex samba-smbd
sudo rsync -aHAX --info=progress2 /data/ /media/
```

Afterwards update the *arr root folders and Transmission locations, then drop
`/data` from `hardware-configuration.nix`. The BX500 is QLC and DRAM-less, so
budget several hours.

### Power

Idle measures 1.63 W package, 99 % core C10, 99.97 % GFX RC6. The package stays
at PC2 and cannot go deeper: the Kingston NV2 reports `ASPM not supported`, and
the BX500 carries libata's `nolpm` quirk, so its SATA link is forced to
`max_power`. Either one alone pins PC2, so pulling the Kingston does not reach
PC8/PC10 while the 4 TB SATA disk is fitted. Firmware also sets `FADT indicates
ASPM is unsupported`, which makes `pcie_aspm.policy=` a no-op.

### Set outside Nix

Plex hardware transcoding and library paths, Immich's QSV toggle, and
`smbpasswd -a win`.
