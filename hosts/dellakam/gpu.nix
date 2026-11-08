{ config, pkgs, ... }:

let
  nvidia-470 = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  nvidia-470-nvenc-unlocked =
    assert nvidia-470.version == "470.256.02";
    nvidia-470.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        enc=$out/lib/libnvidia-encode.so.${old.version}
        cp "$enc" "$TMPDIR/libnvidia-encode.orig"
        sed -i 's/\xe8\x55\x1a\xff\xff\x85\xc0\x41\x89\xc4/\xe8\x55\x1a\xff\xff\x29\xc0\x41\x89\xc4/g' "$enc"
        if cmp -s "$enc" "$TMPDIR/libnvidia-encode.orig"; then
          echo "nvidia-patch: NVENC session-limit pattern not found in $enc" >&2
          exit 1
        fi
      '';
    });
  nv-codec-headers-11 = pkgs.nv-codec-headers-11.overrideAttrs (_: rec {
    version = "11.1.5.4";
    src = pkgs.fetchgit {
      url = "https://git.videolan.org/git/ffmpeg/nv-codec-headers.git";
      rev = "n${version}";
      hash = "sha256-oDIzqeSx9YCp674qhveMzi+0gjaR5H4+W12E0/7EFjE=";
    };
  });

  # Rebuilt from source once per ffmpeg bump (no binary cache for this variant).
  jellyfin-ffmpeg-kepler = pkgs.jellyfin-ffmpeg.override {
    ffmpeg_8-full = pkgs.ffmpeg_8-full.override {
      nv-codec-headers-12 = nv-codec-headers-11;
    };
  };
in
{
  nixpkgs.config.nvidia.acceptLicense = true;

  # Enables hardware.nvidia (no X server is started on this headless box).
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = nvidia-470-nvenc-unlocked;
    open = false; # Kepler has no open-module support
    modesetting.enable = false; # headless; leave the console to i915
    nvidiaPersistenced = true; # keep the GPU initialised: idles in P8, no NVENC cold start
    videoAcceleration = false; # keep VA-API Intel-only; Plex uses the iGPU
    nvidiaSettings = false; # GUI tool; on 470 it pulls in the deprecated gtk2
  };

  # Immich calls `ffmpeg`/`ffprobe` from PATH. Its wrapper only *appends* the stock
  # jellyfin-ffmpeg, so this build wins without rebuilding Immich itself.
  systemd.services.immich-server = {
    path = [ jellyfin-ffmpeg-kepler ];
    # /dev/nvidia* (incl. nvidia-uvm, needed by CUDA filters) must exist when the
    # unit's DeviceAllow list is resolved at start.
    wants = [ "nvidia-persistenced.service" ];
    after = [ "nvidia-persistenced.service" ];
  };

  environment.systemPackages = [ pkgs.nvtopPackages.full ];
}
