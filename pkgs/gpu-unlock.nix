{ lib
, stdenv
, stdenvNoCC
, fetchFromGitHub
, fetchurl
, kernel
, kernelModuleMakeFlags
, python3
, zstd
}:

let
  version = "2.0.0";
  firmwareVersion = "610.43.03";

  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    rev = "7eb51bccae0a0b7e599e084d971170e9a1e82d0c";
    hash = "sha256-1KD/J1S1uyI5GGoTwQ1cU/sXeEKlG54exSvi6U+j73M=";
  };

  nvidiaSource = fetchurl {
    url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-${firmwareVersion}.tar.xz";
    hash = "sha256-fhGJI8eiPtw2EU1jJzpG4+BOmvmGlaQiA+esLf6fwdw=";
  };

  nvidiaInstaller = fetchurl {
    url = "https://download.nvidia.com/XFree86/Linux-x86_64/${firmwareVersion}/NVIDIA-Linux-x86_64-${firmwareVersion}-no-compat32.run";
    hash = "sha256-4IRFHbcwpt8p09dPZVdJxNI248lF99lLUgXoQxj+L5A=";
  };

  firmware = stdenvNoCC.mkDerivation {
    pname = "gpu-unlock-firmware";
    version = "${version}-${firmwareVersion}";
    inherit src;

    nativeBuildInputs = [ python3 zstd ];
    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      mkdir nvidia-source
      tar -xf ${nvidiaSource} -C nvidia-source --strip-components=1
      python3 firmware/extract_gsp.py ${nvidiaInstaller} build/firmware
      python3 firmware/extract_boot_assets.py nvidia-source build/firmware
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make install-firmware install-licenses \
        DESTDIR="$out" \
        FWDIR="/lib/firmware/gpu-unlock/${firmwareVersion}" \
        LICENSEDIR="/share/licenses" \
        ASSETS="$PWD/build/firmware"
      runHook postInstall
    '';

    meta = {
      description = "Pinned NVIDIA firmware assets for gpu-unlock";
      homepage = "https://github.com/Zagitta/gpu-unlock";
      license = lib.licenses.unfree;
      sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
stdenv.mkDerivation {
  __structuredAttrs = true;
  strictDeps = true;
  pname = "gpu-unlock";
  version = "${version}-${kernel.version}";
  inherit src;
  sourceRoot = "${src.name}/kernel/gpu_unlock";

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];
  dontStrip = true;
  dontPatchELF = true;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M="$PWD" modules_install "''${makeFlags[@]}" \
      INSTALL_MOD_PATH="$out" INSTALL_MOD_DIR=extra
    install -Dm644 ../../licenses/GPL-2.0.txt \
      "$out/share/licenses/gpu-unlock/GPL-2.0.txt"
    runHook postInstall
  '';

  passthru = { inherit firmware; };

  meta = {
    description = "Pre-driver tensor throughput unlock for supported GeForce GPUs";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
