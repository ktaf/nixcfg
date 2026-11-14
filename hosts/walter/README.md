# Walter

Named after Walter Bishop from *Fringe*. My local AI workstation for trying
models and experimenting with llama.cpp and vLLM.

Intel i5-13400, RTX 3090, 32 GB RAM, and a 512 GB Samsung NVMe on a Gigabyte
H610M S2H V2. Runs NixOS with kernel 7.3, NVIDIA's open kernel modules, and my
usual Zsh setup.

Chat, coding, and images run as native NixOS services. llama-swap loads one GPU
workload at a time and keeps it warm until switching. It waits for queued images
before switching to chat. ComfyUI stays running with its GPU models unloaded, so
job history survives a switch.

| Use | Address |
| --- | --- |
| Open WebUI: chat and image generation | http://192.168.1.148:8080 |
| ComfyUI: image workflows | http://192.168.1.148:8000/comfyui/ |
| Model controls | http://192.168.1.148:8000/ui |
| OpenAI-compatible API | http://192.168.1.148:8000/v1 |

After rebuilding Walter and the laptop's Home Manager configuration, run
`walter-connect` once on the laptop. It copies credentials through SSH; everyday
use needs no tunnel. The laptop uses the IP directly because `walter.local`
does not resolve on this connection. Set the address once in
`hosts/t14g5-hm/walter.nix` and reserve it in the router's DHCP settings.
`walter.local` is optional when mDNS works. Only the wired LAN interface opens
ports 8000 and 8080.

If OpenCode is already running, run `opencode reload` after copying credentials.

Open WebUI's initial login is `kourosh@walter.local`; its password is in
`~/.config/walter/admin-password`. For ComfyUI and model controls, use `kourosh`
and the contents of `~/.config/walter/api-key` at the browser's login prompt.
These HTTP endpoints are for the trusted LAN. Use a VPN or HTTPS for remote access.

`opencode-walter` and `claude-walter` use `walter-coder`. Other harnesses can use
the API address, model name, and API key above. OpenCode keeps 25% context room
for compaction. Claude's launcher declares the same 64K context and 8K output
limit; local model compatibility still depends on the harness.

The default Huihui 27B model uses full GPU offload, 64K context, F16 KV cache,
and one slot. A 250 W GPU limit reduces heat during long sessions; check physical
cooling if throttling continues. RAM spikes can use zram. Increasing context or
running another GPU process can exhaust VRAM.

ComfyUI includes SDXL Turbo and a four-step 512px workflow in Saved Workflows.
Use Manager → Model Manager to download models directly onto Walter. Manager
uses its legacy interface; Python dependencies and core updates stay in Nix.
Open WebUI uses that workflow too. Existing Qwen/LTX weights are linked read-only
from `~/models`; they still need matching encoders, VAEs, and workflows.
Images and workflows live in `/var/lib/comfyui`, chats in `/var/lib/open-webui`.
The `comfyui` group can read image files. Server settings are managed by Nix;
Open WebUI admin setting changes do not survive a restart. File attachments use
full context; no separate embedding model is loaded.

`vllm.nix` retains the manual Docker experiment; native CUDA vLLM is marked broken
in this pin. Before `llama-serve` or
`vllm-serve`, stop `llama-swap` with systemctl; restart it when finished. Both
manual wrappers use localhost port 8002, separate from the shared API.

The NVMe uses btrfs with zstd compression, `noatime`, async TRIM, monthly scrubs,
and SMART monitoring. The original partition and subvolume layout is preserved.

`gpu-unlock.nix` adds [gpu-unlock](https://github.com/Zagitta/gpu-unlock) as an
experiment for the RTX 3090. Source and firmware are pinned, and it runs before
NVIDIA loads. Its benefit on this machine still needs measuring. For a stock
baseline, remove its import, rebuild, and power-cycle. For a single boot, remove
`gpu_unlock.targets=0000:01:00.0` in the bootloader editor.
