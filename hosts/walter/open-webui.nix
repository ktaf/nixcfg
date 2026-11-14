{ ... }:

{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    environmentFile = "/var/lib/walter-ai/environment";
    environment = {
      WEBUI_URL = "http://walter.local:8080";
      WEBUI_AUTH = "true";
      WEBUI_ADMIN_NAME = "Kourosh";
      WEBUI_ADMIN_EMAIL = "kourosh@walter.local";
      ENABLE_SIGNUP = "false";
      ENABLE_PERSISTENT_CONFIG = "false";
      ENABLE_OLLAMA_API = "false";
      OPENAI_API_BASE_URL = "http://127.0.0.1:8000/v1";
      DEFAULT_MODELS = "walter-coder";
      ENABLE_IMAGE_GENERATION = "true";
      IMAGE_GENERATION_ENGINE = "comfyui";
      COMFYUI_BASE_URL = "http://127.0.0.1:8000/upstream/comfyui_webui";
      COMFYUI_WORKFLOW = builtins.readFile ./workflows/sdxl-turbo-api.json;
      COMFYUI_WORKFLOW_NODES = builtins.toJSON [
        { type = "model"; node_ids = [ "4" ]; key = "ckpt_name"; }
        { type = "prompt"; node_ids = [ "6" ]; key = "text"; }
        { type = "width"; node_ids = [ "5" ]; key = "width"; }
        { type = "height"; node_ids = [ "5" ]; key = "height"; }
        { type = "steps"; node_ids = [ "3" ]; key = "steps"; }
        { type = "seed"; node_ids = [ "3" ]; key = "seed"; }
      ];
      IMAGE_GENERATION_MODEL = "sd_xl_turbo_1.0_fp16.safetensors";
      IMAGE_SIZE = "512x512";
      IMAGE_STEPS = "4";
      HF_HUB_OFFLINE = "1";
      RAG_EMBEDDING_MODEL = "";
      BYPASS_EMBEDDING_AND_RETRIEVAL = "true";
      RAG_EMBEDDING_MODEL_AUTO_UPDATE = "false";
      WHISPER_MODEL_AUTO_UPDATE = "false";
    };
  };

  systemd.services.open-webui = {
    requires = [ "walter-ai-credentials.service" ];
    after = [ "walter-ai-credentials.service" "llama-swap.service" ];
    serviceConfig.Restart = "on-failure";
  };
}
