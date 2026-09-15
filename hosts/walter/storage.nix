{ lib, ... }:

let
  mountOptions = [ "noatime" "compress=zstd:1" "discard=async" ];
in
{
  disko.devices.disk = {
    media = {
      type = "disk";
      device = "/dev/disk/by-id/ata-CT4000BX500SSD1_2522E9C1AC01";
      content = {
        type = "gpt";
        partitions.media = {
          device = "/dev/disk/by-id/ata-CT4000BX500SSD1_2522E9C1AC01-part1";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "walter-media" ];
            mountpoint = "/media";
            inherit mountOptions;
          };
        };
      };
    };
    fast = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-CT1000P5PSSD8_21303083DCC2";
      content = {
        type = "gpt";
        partitions.fast = {
          device = "/dev/disk/by-id/nvme-CT1000P5PSSD8_21303083DCC2-part1";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "walter-fast" ];
            mountpoint = "/fast";
            inherit mountOptions;
          };
        };
      };
    };
  };

  fileSystems = lib.genAttrs [ "/" "/home" "/nix" ] (_: {
    options = mountOptions;
  });

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/data" "/media" "/fast" ];
    interval = "monthly";
  };

  services.fstrim.enable = true;
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  systemd.tmpfiles.settings."20-fast" = {
    "/fast/apps".d = { mode = "0750"; user = "root"; group = "root"; };
    "/fast/vms".d = { mode = "0750"; user = "root"; group = "root"; };
    "/fast/plex-transcode".d = { mode = "0700"; user = "plex"; group = "plex"; };
  };

  systemd.services.systemd-tmpfiles-setup.unitConfig.RequiresMountsFor = [
    "/data"
    "/media"
    "/fast"
  ];
  systemd.services.systemd-tmpfiles-resetup.unitConfig.RequiresMountsFor = [
    "/data"
    "/media"
    "/fast"
  ];
}
