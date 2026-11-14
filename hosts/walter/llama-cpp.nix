{ pkgs, ... }:

let
  llamaCpp = pkgs.llama-cpp.override { cudaSupport = true; };
in
{
  services.llama-cpp = {
    enable = true;
    package = llamaCpp;
    settings = {
      host = "127.0.0.1";
      port = 8001;
      model = "/var/lib/llama-swap/models/Huihui-Qwen3.8-27B-abliterated-UD-Q4_K_XL.gguf";
      alias = "walter-coder";
      ctx-size = 65536;
      parallel = 1;
      n-gpu-layers = "all";
      fit = "off";
      flash-attn = "on";
      cache-type-k = "f16";
      cache-type-v = "f16";
      jinja = true;
    };
  };

  environment.systemPackages = [
    llamaCpp
    (pkgs.writeShellApplication {
      name = "llama-serve";
      runtimeInputs = [ llamaCpp ];
      text = ''
        if [ "$#" -eq 0 ]; then
          echo 'Usage: llama-serve --model /path/to/model.gguf [llama.cpp options]' >&2
          exit 2
        fi

        export LLAMA_ARG_HOST="''${LLAMA_ARG_HOST:-127.0.0.1}"
        export LLAMA_ARG_PORT="''${LLAMA_ARG_PORT:-8002}"
        export LLAMA_ARG_CTX_SIZE="''${LLAMA_ARG_CTX_SIZE:-65536}"
        exec llama-server "$@"
      '';
    })
  ];
}
