{ lib, pkgs, user, ... }:

let
  python = pkgs.python3.override {
    packageOverrides = _final: prev: {
      torch = prev.torch-bin;
      torchvision = prev.torchvision-bin;
      torchaudio = prev.torchaudio-bin;
    };
  };
  ggufNodes = pkgs.callPackage ../../pkgs/comfyui-gguf.nix { };
in
{
  services.comfyui = {
    enable = true;
    package = pkgs.comfyui.override { python3 = python; };
    listen = [ "127.0.0.1" ];
    port = 8188;
    extraPackages = ps: [ ps.gguf ps.comfyui-manager ];
    extraArgs = [
      "--disable-auto-launch"
      "--preview-method=auto"
      "--enable-manager"
      "--enable-manager-legacy-ui"
    ];
    models = [
      {
        name = "sd_xl_turbo_1.0_fp16.safetensors";
        url = "https://huggingface.co/stabilityai/sdxl-turbo/resolve/71153311d3dbb46851df1931d3ca6e939de83304/sd_xl_turbo_1.0_fp16.safetensors";
        hash = "sha256-6GmsfWlCyzJ9aNXtg6QER6rfIODDNY2YssyeJw2w2iY=";
        installPaths = "checkpoints";
      }
    ];
  };

  systemd.services.comfyui = {
    path = [ pkgs.git ];
    wants = [ "walter-gpu-power.service" ];
    after = [ "walter-gpu-power.service" ];
    environment = {
      HOME = "/var/lib/comfyui";
      HF_HOME = "/var/cache/comfyui/huggingface";
      TORCH_HOME = "/var/cache/comfyui/torch";
      XDG_CONFIG_HOME = "/var/lib/comfyui/config";
      PYTHONPYCACHEPREFIX = "/var/cache/comfyui/pycache";
    };
    preStart = lib.mkAfter ''
      mkdir -p /var/lib/comfyui/user/default/workflows /var/lib/comfyui/models/diffusion_models
      ln -sfn ${ggufNodes} /var/lib/comfyui/custom_nodes/ComfyUI-GGUF
      ln -sfn ${./workflows/sdxl-turbo.json} /var/lib/comfyui/user/default/workflows/sdxl-turbo.json
      for name in ltx-2.3-22b-dev-Q6_K.gguf ltx-2.3-22b-uncensored-Q6_K.gguf qwen-image-2.1-F16.gguf qwen-image-edit-2511-Q6_K.gguf; do
        ln -sfn "/var/lib/comfyui/walter-models/$name" "/var/lib/comfyui/models/diffusion_models/$name"
      done
    '';
    serviceConfig = {
      CacheDirectory = "comfyui";
      StateDirectoryMode = lib.mkForce "0770";
      SupplementaryGroups = [ "video" "render" ];
      BindReadOnlyPaths = [ "/home/${user}/models:/var/lib/comfyui/walter-models" ];
    };
  };
}
