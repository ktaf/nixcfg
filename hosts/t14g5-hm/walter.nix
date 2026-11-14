{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    mutableSettings = true;
    settings = {
      model = "walter/walter-coder";
      providers.walter = {
        package = "@opencode/ai/providers/openai-compatible";
        settings = {
          baseURL = "http://walter.local:8000/v1";
          apiKey = "{file:${config.xdg.configHome}/walter/api-key}";
        };
        models.walter-coder = {
          capabilities = {
            tools = true;
            input = [ "text" ];
            output = [ "text" ];
          };
          limit = {
            context = 65536;
            output = 8192;
          };
        };
      };
      compaction = {
        auto = true;
        buffer = "25%";
        keep.tokens = 4096;
      };
    };
  };

  home.packages = [
    (pkgs.writeShellApplication {
      name = "walter-connect";
      runtimeInputs = [ pkgs.openssh pkgs.coreutils ];
      text = ''
        host="''${1:-walter.local}"
        credentials="''${XDG_CONFIG_HOME:-$HOME/.config}/walter"
        umask 077
        mkdir -p "$credentials"
        ssh -o IPQoS=none -o ConnectTimeout=10 "kourosh@$host" \
          'cat /var/lib/walter-ai/api-key /var/lib/walter-ai/admin-password' > "$credentials/bootstrap"
        head -n 1 "$credentials/bootstrap" > "$credentials/api-key"
        tail -n 1 "$credentials/bootstrap" > "$credentials/admin-password"
        rm "$credentials/bootstrap"
        printf 'Credentials saved in %s\nChat: http://walter.local:8080\nImages: http://walter.local:8000/comfyui/\n' "$credentials"
      '';
    })
    (pkgs.writeShellApplication {
      name = "opencode-walter";
      runtimeInputs = [ pkgs.opencode ];
      text = ''
        export OPENCODE_CONFIG=${config.xdg.configHome}/opencode/home-manager.json
        exec opencode "$@"
      '';
    })
    (pkgs.writeShellApplication {
      name = "claude-walter";
      runtimeInputs = [ pkgs.claude-code pkgs.coreutils ];
      text = ''
        export ANTHROPIC_BASE_URL=http://walter.local:8000
        ANTHROPIC_AUTH_TOKEN="$(cat "''${XDG_CONFIG_HOME:-$HOME/.config}/walter/api-key")"
        export ANTHROPIC_AUTH_TOKEN
        export ANTHROPIC_MODEL=walter-coder
        export ANTHROPIC_CUSTOM_MODEL_OPTION=walter-coder
        export ANTHROPIC_DEFAULT_SONNET_MODEL=walter-coder
        export ANTHROPIC_DEFAULT_OPUS_MODEL=walter-coder
        export ANTHROPIC_DEFAULT_HAIKU_MODEL=walter-coder
        export CLAUDE_CODE_MAX_OUTPUT_TOKENS=8192
        export CLAUDE_CODE_MAX_CONTEXT_TOKENS=65536
        export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
        exec claude "$@"
      '';
    })
  ];

  xdg.desktopEntries = {
    walter-chat = {
      name = "Walter Chat";
      exec = "xdg-open http://walter.local:8080";
      icon = "internet-web-browser";
      terminal = false;
      categories = [ "Network" ];
    };
    walter-images = {
      name = "Walter Images";
      exec = "xdg-open http://walter.local:8000/comfyui/";
      icon = "applications-graphics";
      terminal = false;
      categories = [ "Graphics" ];
    };
  };
}
