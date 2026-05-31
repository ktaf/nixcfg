{ pkgs, ... }:

{
  systemd.services.bc250-cu-live-unlock = {
    description = "BC-250 live CU/WGP unlock via UMR";
    wantedBy = [ "multi-user.target" ];
    after = [
      "systemd-udev-settle.service"
      "systemd-modules-load.service"
    ];
    wants = [ "systemd-udev-settle.service" ];

    path = with pkgs; [
      bash
      coreutils
      gnugrep
      pciutils
      umr
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail

      ASIC="cyan_skillfish.gfx1013"
      REG_CC="mmCC_GC_SHADER_ARRAY_CONFIG"
      REG_SPI="mmSPI_PG_ENABLE_STATIC_WGP_MASK"
      REG_RLC="mmRLC_PG_ALWAYS_ON_WGP_MASK"

      # Per-row WGP masks. 0x1f enables WGP0-4, i.e. 10 CUs per row.
      MASK_SE0_SH0="0x1f"
      MASK_SE0_SH1="0x1f"
      MASK_SE1_SH0="0x1f"
      MASK_SE1_SH1="0x1f"
      RLC_MASK="0x1f"

      if ! lspci -nn | grep -qi '\[1002:13fe\]'; then
        echo "BC-250 PCI ID 1002:13fe not found; refusing register writes" >&2
        exit 1
      fi

      for _ in $(seq 1 30); do
        if ls /dev/dri/renderD* >/dev/null 2>&1; then
          break
        fi
        sleep 1
      done

      if ! ls /dev/dri/renderD* >/dev/null 2>&1; then
        echo "no DRM render node found; amdgpu is not ready" >&2
        exit 1
      fi

      umr_instance=""
      bdf=""
      while IFS= read -r line; do
        case "$line" in
          *"[1002:13fe]"*)
            bdf="''${line%% *}"
            break
            ;;
        esac
      done < <(lspci -Dnn)

      if [ -n "$bdf" ] && [ -d /sys/kernel/debug/dri ]; then
        for name in /sys/kernel/debug/dri/*/name; do
          [ -e "$name" ] || continue
          inst="''${name%/name}"
          inst="''${inst##*/}"
          case "$inst" in
            ""|*[!0-9]*)
              continue
              ;;
          esac
          if [ "$inst" -lt 128 ] && grep -Fqi "$bdf" "$name"; then
            umr_instance="$inst"
            break
          fi
        done
      fi

      umr_call() {
        if [ -n "$umr_instance" ]; then
          umr -i "$umr_instance" "$@"
        else
          umr "$@"
        fi
      }

      umr_output_failed() {
        printf '%s\n' "$1" | grep -Eqi '(\[ERROR\]|error|failed|invalid|unknown|cannot|no such)'
      }

      umr_write() {
        local out rc
        set +e
        out="$(umr_call -w "$@" 2>&1)"
        rc=$?
        set -e
        [ -z "$out" ] || printf '%s\n' "$out"
        if [ "$rc" -ne 0 ] || umr_output_failed "$out"; then
          echo "UMR write failed: $*" >&2
          exit 1
        fi
      }

      write_row() {
        local se="$1"
        local sh="$2"
        local mask="$3"

        echo "unlocking SE$se.SH$sh: CC=0x0 SPI=$mask"
        umr_write "$ASIC.$REG_CC" 0x0 -b "$se" "$sh" 0xffffffff
        umr_write "$ASIC.$REG_SPI" "$mask" -b "$se" "$sh" 0xffffffff
      }

      if [ -n "$umr_instance" ]; then
        echo "using UMR instance $umr_instance for $bdf"
      else
        echo "using default UMR instance"
      fi

      write_row 0 0 "$MASK_SE0_SH0"
      write_row 0 1 "$MASK_SE0_SH1"
      write_row 1 0 "$MASK_SE1_SH0"
      write_row 1 1 "$MASK_SE1_SH1"

      echo "setting $REG_RLC=$RLC_MASK"
      umr_write "$ASIC.$REG_RLC" "$RLC_MASK"
    '';
  };
}
