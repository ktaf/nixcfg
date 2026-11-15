{ config, pkgs, ... }:
let
  user = "ktaf";
in
{
  imports = [
    ../../_modules/git.nix
    ./walter.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.google-chrome = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--use-angle=vulkan"
      "--enable-features=Vulkan,VulkanFromANGLE"
    ];
  };

  xdg.enable = true;

  # Ease usage on non-NixOS installations
  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };

  desktop.quickshell = {
    enable = true;
    lockCommand = [ "/usr/bin/swaylock" "-f" ];
  };

  services = {
    systembus-notify.enable = true;
    blueman-applet.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ]; # to suport user-installed binaries like uv

    sessionVariables = {
      # Wayland configuration
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      # Used by the nixpkgs Chrome wrapper even outside NixOS.
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # Graphics
      WLR_RENDERER = "vulkan";
      GSK_RENDERER = "gl";
      XCURSOR_THEME = "Adwaita";

      # Default applications
      SHELL = "$HOME/.nix-profile/bin/zsh";
      TERMINAL = "alacritty";
      VISUAL = "code --wait";
      EDITOR = "code --wait";
      BROWSER = "google-chrome-stable";
      PAGER = "less";

      # Miscellaneous
      DOCKER_CONFIG = "$HOME/.config/docker";
      LESSHISTFILE = "-";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      # Work
      KUBE_EDITOR = "code -w";
      TENV_DETACHED_PROXY = "false";
      TG_LOG_FORMAT = "bare";
      TERRAGRUNT_QUIET = "true";
      TG_PARALLELISM = "4";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";

      OLLAMA_IGPU_ENABLE = "1";
    };

    packages = with pkgs; [
      antigravity-cli
      antigravity-ide
      azure-cli
      azure-cli-extensions.costmanagement
      azure-cli-extensions.fzf
      azure-cli-extensions.resource-graph
      azure-cli-extensions.quota
      bat
      bitwarden-desktop
      blueman
      claude-code
      claude-agent-acp
      codex
      codex-acp
      comfyui
      eza
      ffmpeg
      fzf
      go
      goose-cli
      herdr
      htop
      inframap
      k9s
      kind
      krew
      kubectl
      kubectx
      kubelogin
      kubernetes-helm
      kubeseal
      libdigidocpp
      libinput
      mcp-grafana
      mesa-demos
      mission-center
      ripgrep
      fastfetch
      nmap
      obsidian
      ollama-vulkan
      rizin
      pi-coding-agent
      pinact
      pre-commit
      pulseaudio
      qdigidoc
      remmina
      sshfs
      subnetcalc
      telegram-desktop
      tenv
      terraform-docs
      terraform-mcp-server
      tfautomv
      tflint
      unsloth-desktop
      usbview
      uv
      v4l-utils
      virt-manager
      vsh
      wayvnc
      whois
      winbox
      yamllint
      yq
      nodejs_26
      slack
      vscode
      rtk
      gh
      gnumake
      gcc
    ];
  };

  programs.git = {
    lfs.enable = true;
    settings = {
      core.editor = "code --wait";
      push.autoSetupRemote = true;
    };
  };

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

  xdg.configFile."systemd/user/snap.prompting-client.daemon.service.d/90-require-apparmor.conf".text = ''
    [Unit]
    ConditionPathExists=/sys/kernel/security/apparmor/features
  '';

  xdg.configFile."swaylock/config".text = ''
    image=${config.home.homeDirectory}/mario.gif
  '';
}
