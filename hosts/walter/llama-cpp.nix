{ pkgs, ... }:

let
  llamaCpp = pkgs.llama-cpp.override { cudaSupport = true; };
in
{
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

        exec llama-server \
          --host 127.0.0.1 \
          --port 8000 \
          --ctx-size 4096 \
          --n-gpu-layers auto \
          "$@"
      '';
    })
  ];
}
