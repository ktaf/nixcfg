{ config, lib, pkgs, ... }:
let
  cfg = config.desktop.quickshell;
  modifier = config.wayland.windowManager.sway.config.modifier;
  backend = pkgs.writeShellApplication {
    name = "quickshell-backend";
    runtimeInputs = with pkgs; [ python3 networkmanager pulseaudio sway cliphist wl-clipboard brightnessctl bluez ];
    text = ''exec python3 ${./quickshell/backend.py} "$@"'';
  };
  commands = {
    status = [ "${backend}/bin/quickshell-backend" "status" ];
    clipboard = [ "${backend}/bin/quickshell-backend" "clipboard" ];
    paste = [ "${backend}/bin/quickshell-backend" "paste" ];
    terminal = [ "${pkgs.alacritty}/bin/alacritty" ];
    cpu = [ "${pkgs.alacritty}/bin/alacritty" "-e" "${pkgs.htop}/bin/htop" "-s" "PERCENT_CPU" ];
    memory = [ "${pkgs.alacritty}/bin/alacritty" "-e" "${pkgs.htop}/bin/htop" "-s" "PERCENT_MEM" ];
    mixer = [ "${pkgs.pavucontrol}/bin/pavucontrol" ];
    mute = [ "${pkgs.pulseaudio}/bin/pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle" ];
    volumeUp = [ "${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%" ];
    volumeDown = [ "${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%" ];
    brightnessUp = [ "${pkgs.brightnessctl}/bin/brightnessctl" "set" "+5%" ];
    brightnessDown = [ "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-" ];
    network = [ "${pkgs.networkmanagerapplet}/bin/nm-connection-editor" ];
    wifiOn = [ "${pkgs.networkmanager}/bin/nmcli" "radio" "wifi" "on" ];
    wifiOff = [ "${pkgs.networkmanager}/bin/nmcli" "radio" "wifi" "off" ];
    bluetooth = [ "${pkgs.blueman}/bin/blueman-manager" ];
    bluetoothOn = [ "${pkgs.bluez}/bin/bluetoothctl" "power" "on" ];
    bluetoothOff = [ "${pkgs.bluez}/bin/bluetoothctl" "power" "off" ];
    calendar = [ "${pkgs.gnome-calendar}/bin/gnome-calendar" ];
    lock = cfg.lockCommand;
    suspend = [
      (lib.getExe (pkgs.writeShellApplication {
        name = "quickshell-suspend";
        text = ''
          ${lib.escapeShellArgs cfg.lockCommand}
          exec ${pkgs.systemd}/bin/systemctl suspend
        '';
      }))
    ];
    logout = [ "${pkgs.sway}/bin/swaymsg" "exit" ];
    reboot = [ "${pkgs.systemd}/bin/systemctl" "reboot" ];
    shutdown = [ "${pkgs.systemd}/bin/systemctl" "poweroff" ];
  };
  settings = pkgs.writeText "Settings.qml" ''
    pragma Singleton
    import QtQuick
    QtObject {
      readonly property var commands: ${builtins.toJSON commands}
      readonly property string fontFamily: ${builtins.toJSON cfg.font}
      readonly property int barHeight: ${toString cfg.barHeight}
      readonly property bool notificationsEnabled: ${lib.boolToString cfg.notifications.enable}
    }
  '';
  shellConfig = pkgs.runCommand "nixcfg-quickshell" { } ''
    mkdir -p "$out"
    cp ${./quickshell}/*.qml "$out/"
    cp ${settings} "$out/Settings.qml"
    echo 'singleton Settings 1.0 Settings.qml' > "$out/qmldir"
    for file in ${./quickshell}/[A-Z]*.qml; do
      name=$(basename "$file" .qml)
      echo "$name 1.0 $name.qml" >> "$out/qmldir"
    done
  '';
  control = pkgs.writeShellApplication {
    name = "quickshell-control";
    text = ''
      exec ${lib.getExe cfg.package} -c nixcfg ipc call shell toggle "''${1:-launcher}"
    '';
  };
in
{
  # Import this Home Manager module on any Sway host (including HM on NixOS).
  # Set desktop.quickshell.enable = true; then rebuild and log out/in.
  # Set it back to false to restore the existing Waybar/SwayNC/keybindings.
  # Waybar stays installed and its configuration is never rewritten here.
  # On NixOS, import under home-manager.users.<user>.imports, not the system
  # imports list. Requires an existing Sway session and clipboard collectors.
  # Keeps Swayidle/Swaylock, Kanshi, awww, and the network/Bluetooth/audio
  # backends. Device management opens nm-connection-editor/Blueman/pavucontrol.
  # Notification history is in memory, bounded to 100 entries.
  # Menus: Super+r (apps), Super+Shift+V (clipboard), Super+N (notifications),
  # Super+Shift+p (power); or quickshell-control <launcher|clipboard|settings|
  # notifications|power>. notifications.enable = false retains SwayNC.
  options.desktop.quickshell = {
    enable = lib.mkEnableOption "the Quickshell desktop in place of the Sway bar and menus";
    package = lib.mkPackageOption pkgs "quickshell" { };
    font = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Font for the bar and menus.";
    };
    barHeight = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32;
      description = "Height of each output's bar in logical pixels.";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Tallinn";
      description = "Timezone for the clock and calendar.";
    };
    lockCommand = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      default = [ "${pkgs.swaylock}/bin/swaylock" "-f" ];
      description = "Existing screen locker; also used before suspending.";
    };
    notifications.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Replace SwayNC with Quickshell notifications. Disable to retain SwayNC.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.wayland.windowManager.sway.enable && config.wayland.windowManager.sway.systemd.enable;
        message = "desktop.quickshell needs Sway with Home Manager systemd integration enabled.";
      }
      {
        assertion = lib.versionAtLeast cfg.package.version "0.3.0";
        message = "desktop.quickshell needs Quickshell >= 0.3.0 from the host's Nixpkgs (matching Qt).";
      }
    ];

    programs.quickshell = {
      enable = true;
      package = cfg.package;
      configs.nixcfg = shellConfig;
      activeConfig = "nixcfg";
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
    };
    systemd.user.services.quickshell = {
      Unit = {
        PartOf = [ "sway-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        RestartSec = 2;
        Environment = [ "TZ=${cfg.timeZone}" ];
        # Desktop programs launched from QML must have the user's full PATH.
        # All shell control commands themselves use absolute store paths.
      };
    };

    home.packages = [ control pkgs.gnome-calendar pkgs.nerd-fonts.jetbrains-mono ];
    programs.waybar.systemd.enable = lib.mkForce false;
    services.swaync.enable = lib.mkIf cfg.notifications.enable (lib.mkForce false);

    wayland.windowManager.sway.config = {
      bars = lib.mkForce [ ];
      menu = lib.mkForce "${control}/bin/quickshell-control launcher";
      keybindings = lib.mkOptionDefault {
        "${modifier}+r" = lib.mkForce "exec ${control}/bin/quickshell-control launcher";
        "${modifier}+d" = lib.mkForce "exec ${control}/bin/quickshell-control launcher";
        "XF86Search" = lib.mkForce "exec ${control}/bin/quickshell-control launcher";
        "${modifier}+Shift+V" = lib.mkForce "exec ${control}/bin/quickshell-control clipboard";
        "${modifier}+N" = lib.mkIf cfg.notifications.enable (lib.mkForce "exec ${control}/bin/quickshell-control notifications");
        "${modifier}+Shift+p" = "exec ${control}/bin/quickshell-control power";
      };
    };
  };
}
