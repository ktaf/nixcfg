{ config, lib, pkgs, user, ... }:

let
  swapConfig = (pkgs.formats.yaml { }).generate "llama-swap-config.yaml"
    config.services.llama-swap.settings;
  releaseComfyGpu = pkgs.writers.writePython3 "release-comfyui-gpu" { } ''
    import json
    import os
    import signal
    import sys
    import time
    import urllib.error
    import urllib.request

    while True:
        try:
            url = "http://127.0.0.1:8188/queue"
            with urllib.request.urlopen(url, timeout=10) as response:
                queue = json.load(response)
        except urllib.error.URLError:
            try:
                os.kill(int(sys.argv[1]), 0)
            except ProcessLookupError:
                sys.exit(0)
            time.sleep(1)
            continue
        if not queue["queue_running"] and not queue["queue_pending"]:
            break
        time.sleep(1)
    try:
        payload = json.dumps({"unload_models": True, "free_memory": True})
        request = urllib.request.Request(
            "http://127.0.0.1:8188/free",
            data=payload.encode(),
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(request, timeout=10):
            pass
        while True:
            url = "http://127.0.0.1:8188/system_stats"
            with urllib.request.urlopen(url, timeout=10) as response:
                stats = json.load(response)
            if stats["devices"][0]["torch_vram_total"] <= 64 * 1024 * 1024:
                break
            time.sleep(1)
        os.kill(int(sys.argv[1]), signal.SIGINT)
    except ProcessLookupError:
        pass
  '';
  comfyLease = {
    cmd = "${pkgs.coreutils}/bin/sleep infinity";
    cmdStop = "${releaseComfyGpu} \${PID}";
    proxy = "http://127.0.0.1:8188";
    checkEndpoint = "/";
    unlisted = true;
    ttl = 0;
    unloadTimeout = 3600;
  };
in
{
  services.llama-swap = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 8000;
    # The API key exists only at runtime; validate after loading EnvironmentFile.
    validateConfigFile = false;
    settings = {
      apiKeys = [ "\${env.WALTER_AI_API_KEY}" ];
      healthCheckTimeout = 300;
      globalTTL = 0;
      captureBuffer = 0;
      helpagent.disable = true;
      security.cors = {
        allowedOrigins = [
          "http://walter.local:8000"
          "http://walter.local:8080"
          "http://192.168.1.148:8000"
          "http://192.168.1.148:8080"
        ];
        allowCredentials = true;
      };
      models = {
        walter-coder = {
          cmd = config.systemd.services.llama-cpp.serviceConfig.ExecStart;
          proxy = "http://127.0.0.1:8001";
        };
        # Browser sockets stay open; Open WebUI sockets end with each image job.
        comfyui_auto = comfyLease;
        comfyui_webui = comfyLease;
      };
      routing.router = {
        use = "group";
        settings.groups = {
          text = {
            members = [ "walter-coder" ];
            swap = true;
            exclusive = true;
          };
          images = {
            members = [ "comfyui_auto" "comfyui_webui" ];
            swap = false;
            exclusive = true;
          };
        };
      };
    };
  };

  users.users.${user}.extraGroups = [ "comfyui" ];

  systemd.services = {
    # llama-swap owns the LLM process and ComfyUI's GPU reservation.
    llama-cpp.enable = false;

    walter-ai-credentials = {
      description = "Create Walter's local AI credentials";
      before = [ "llama-swap.service" "open-webui.service" ];
      path = [ pkgs.coreutils pkgs.openssl ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "walter-ai";
        StateDirectoryMode = "0755";
        UMask = "0077";
      };
      script = ''
        cd /var/lib/walter-ai
        for name in api-key admin-password webui-secret; do
          if [ ! -s "$name" ]; then
            openssl rand -hex 32 > "$name"
          fi
        done
        chown ${lib.escapeShellArg user} api-key admin-password
        chmod 0400 api-key admin-password
        printf 'WALTER_AI_API_KEY=%s\n' "$(cat api-key)" > gateway-environment
        {
          printf 'OPENAI_API_KEY=%s\n' "$(cat api-key)"
          printf 'COMFYUI_API_KEY=%s\n' "$(cat api-key)"
          printf 'WEBUI_ADMIN_PASSWORD=%s\n' "$(cat admin-password)"
          printf 'WEBUI_SECRET_KEY=%s\n' "$(cat webui-secret)"
        } > environment
      '';
    };

    walter-gpu-power = {
      description = "Limit RTX 3090 heat during sustained inference";
      wantedBy = [ "multi-user.target" ];
      after = [ "nvidia-persistenced.service" ];
      before = [ "llama-swap.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --power-limit=250";
      };
    };

    llama-swap = {
      requires = [ "walter-ai-credentials.service" "comfyui.service" ];
      wants = [ "walter-gpu-power.service" ];
      after = [ "walter-ai-credentials.service" "walter-gpu-power.service" "comfyui.service" ];
      environment = {
        HOME = "/var/lib/llama-swap";
        HF_HOME = "/var/cache/llama-swap/huggingface";
        TORCH_HOME = "/var/cache/llama-swap/torch";
        XDG_CONFIG_HOME = "/var/lib/llama-swap/config";
        PYTHONPYCACHEPREFIX = "/var/cache/llama-swap/pycache";
      };
      serviceConfig = {
        User = "comfyui";
        Group = "comfyui";
        SupplementaryGroups = [ "video" "render" ];
        DynamicUser = lib.mkForce false;
        StateDirectory = "llama-swap";
        StateDirectoryMode = "0770";
        WorkingDirectory = lib.mkForce "/var/lib/llama-swap";
        BindReadOnlyPaths = [ "/home/${user}/models:/var/lib/llama-swap/models" "/proc/cpuinfo" ];
        EnvironmentFile = "/var/lib/walter-ai/gateway-environment";
        ExecStartPre = "${lib.getExe pkgs.llama-swap} -validate -config ${swapConfig}";
        ProcSubset = lib.mkForce "all";
        KillMode = "mixed";
        TimeoutStopSec = "65min";
      };
    };
  };
}
