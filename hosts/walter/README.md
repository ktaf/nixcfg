# Walter

Named after Walter Bishop from *Fringe*. My local AI workstation for trying
models and experimenting with llama.cpp and vLLM.

Intel i5-13400, RTX 3090, 16 GB RAM, and a 512 GB Samsung NVMe on a Gigabyte
H610M S2H V2. Runs NixOS with kernel 7.3, NVIDIA's open kernel modules, and my
usual Zsh setup.

`llama-cpp.nix` provides native CUDA-enabled llama.cpp. `vllm.nix` keeps vLLM in
its official Docker image, since the native CUDA package is broken in the pinned
Nixpkgs. Models are chosen and started manually:

```sh
llama-serve --model /path/to/model.gguf
vllm-serve --model MODEL_ID --max-model-len 4096
```

Both use `127.0.0.1:8000`. Stop one with Ctrl+C before starting the other.

The NVMe uses btrfs with zstd compression, `noatime`, async TRIM, monthly scrubs,
and SMART monitoring. The original partition and subvolume layout is preserved.

`gpu-unlock.nix` adds [gpu-unlock](https://github.com/Zagitta/gpu-unlock) as an
experiment for the RTX 3090. Source and firmware are pinned, and it runs before
NVIDIA loads. Its benefit on this machine still needs measuring. For a stock
baseline, remove its import, rebuild, and power-cycle. For a single boot, remove
`gpu_unlock.targets=0000:01:00.0` in the bootloader editor.
