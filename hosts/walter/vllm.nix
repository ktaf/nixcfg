{ pkgs, user, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.enable = true;
  users.users.${user}.extraGroups = [ "docker" ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "vllm-serve";
      runtimeInputs = [ pkgs.docker ];
      text = ''
        if [ "$#" -eq 0 ]; then
          echo 'Usage: vllm-serve --model MODEL [vLLM options]' >&2
          exit 2
        fi

        exec docker run --rm --init \
          --device nvidia.com/gpu=all \
          --ipc=host \
          --publish 127.0.0.1:8000:8000 \
          --volume walter-huggingface:/root/.cache/huggingface \
          --env HF_TOKEN \
          vllm/vllm-openai:v0.32.0 \
          --host 0.0.0.0 "$@"
      '';
    })
  ];
}
