pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io

ShellRoot {
    id: root
    property string panel: ""
    property string panelScreen: ""
    property var status: ({})
    property var notificationService: notificationLoader.item

    function toggle(name) {
        if (!["launcher", "clipboard", "settings", "notifications", "power"].includes(name)) return;
        const screen = I3.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
        panel = panel === name && panelScreen === screen ? "" : name;
        panelScreen = screen;
    }
    function run(command) {
        if (command && command.length) Quickshell.execDetached(command);
    }

    IpcHandler {
        target: "shell"
        function toggle(name: string): void { root.toggle(name); }
        function status(): string {
            return JSON.stringify({panel: root.panel, notifications: root.notificationService?.items.values.length ?? 0});
        }
    }
    Process {
        id: statusProcess
        command: Settings.commands.status
        running: true
        stdout: SplitParser {
            onRead: data => {
                try { root.status = JSON.parse(data); }
                catch (error) { console.warn("Status:", error); }
            }
        }
        onExited: statusRestart.restart()
    }
    Timer { id: statusRestart; interval: 5000; onTriggered: statusProcess.running = true }
    Loader {
        id: notificationLoader
        active: Settings.notificationsEnabled
        sourceComponent: Notifications { }
    }
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property var modelData
            Bar { screen: modelData; shell: root }
            MenuWindow {
                screen: modelData
                shell: root
                visible: root.panel !== "" && root.panelScreen === modelData.name
            }
            NotificationPopups { targetScreen: modelData; shell: root }
        }
    }
}
