pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray

PanelWindow {
    id: bar
    required property var shell
    anchors { top: true; left: true; right: true }
    implicitHeight: Settings.barHeight
    color: "#cc1a1b26"
    property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3
        Chip { text: "󱄅"; foreground: "#7a95c9"; onClicked: bar.shell.toggle("launcher") }
        Repeater {
            model: I3.workspaces
            Chip {
                required property var modelData
                visible: modelData.monitor?.name === bar.screen.name
                text: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"][modelData.number - 1] ?? modelData.name
                tooltip: modelData.name
                selected: modelData.active
                foreground: modelData.urgent ? "#ec2e37" : modelData.active ? "#ecd3a0" : "#7a95c9"
                onClicked: modelData.activate()
            }
        }
        Chip { text: " " + (bar.shell.status.cpu ?? "–") + "%"; foreground: "#fb958b"; visible: bar.width > 1250; onClicked: bar.shell.run(Settings.commands.cpu) }
        Chip { text: " " + (bar.shell.status.memory ?? "–") + "%"; foreground: "#a1c999"; visible: bar.width > 1100; onClicked: bar.shell.run(Settings.commands.memory) }
        Chip { text: " " + bar.shell.status.temperature + "°"; visible: bar.width > 1450 && bar.shell.status.temperature != null; foreground: bar.shell.status.temperature >= 70 ? "#ec2e37" : "#7a95c9" }
        Chip { text: "󰋊 " + (bar.shell.status.disk ?? "–") + "%"; foreground: "#b48ead"; visible: bar.width > 1550 }
        Item { Layout.fillWidth: true }
        Chip {
            text: bar.player ? (bar.player.isPlaying ? "▶ " : "⏸ ") + bar.player.trackTitle : ""
            tooltip: bar.player ? bar.player.trackTitle + "\n" + bar.player.trackArtist : ""
            visible: bar.player !== null && bar.width > 1200
            maximumWidth: Math.max(100, Math.min(340, bar.width * 0.18))
            onClicked: { if (bar.player?.canTogglePlaying) bar.player.togglePlaying(); }
            onRightClicked: { if (bar.player?.canGoNext) bar.player.next(); }
        }
        Item { Layout.fillWidth: true }
        Chip {
            text: clock.date.toLocaleString(Qt.locale(), bar.width > 1350 ? "ddd, dd MMM  HH:mm" : "HH:mm")
            tooltip: clock.date.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm:ss")
            onClicked: bar.shell.run(Settings.commands.calendar)
            SystemClock { id: clock; precision: SystemClock.Seconds }
        }
        Chip {
            text: "☀ " + bar.shell.status.brightness + "%"
            visible: bar.shell.status.brightness != null && bar.width > 1300
            foreground: "#ecd3a0"
            onScrolled: up => bar.shell.run(up ? Settings.commands.brightnessUp : Settings.commands.brightnessDown)
        }
        Chip {
            text: bar.shell.status.muted ? "󰝟" : " " + (bar.shell.status.volume ?? "–") + "%"
            foreground: bar.shell.status.muted ? "#fb958b" : "#81a1c1"
            onClicked: bar.shell.run(Settings.commands.mixer)
            onRightClicked: bar.shell.run(Settings.commands.mute)
            onScrolled: up => bar.shell.run(up ? Settings.commands.volumeUp : Settings.commands.volumeDown)
        }
        Chip {
            visible: bar.shell.status.battery != null
            text: (bar.shell.status.battery?.state === "Charging" ? " " : "󰁹 ") + (bar.shell.status.battery?.percent ?? "") + "%"
            tooltip: bar.shell.status.battery ? bar.shell.status.battery.name + ": " + bar.shell.status.battery.state : ""
            foreground: (bar.shell.status.battery?.percent ?? 100) < 20 ? "#fb958b" : "#8fbcbb"
        }
        Chip { text: "Caps"; visible: bar.shell.status.capslock === true; foreground: "#ecd3a0" }
        Chip { text: "Num"; visible: bar.shell.status.numlock === true && bar.width > 1450 }
        Chip {
            text: "󰤨"
            tooltip: bar.shell.status.network ?? "Network"
            foreground: "#5e81ac"
            onClicked: bar.shell.toggle("settings")
            onRightClicked: bar.shell.run(Settings.commands.network)
        }
        Chip {
            text: bar.shell.status.bluetooth ? "󰂯" : "󰂲"
            foreground: "#5e81ac"
            onClicked: bar.shell.run(Settings.commands.bluetooth)
            onRightClicked: bar.shell.run(bar.shell.status.bluetooth ? Settings.commands.bluetoothOff : Settings.commands.bluetoothOn)
        }
        Repeater {
            model: SystemTray.items
            Rectangle {
                id: trayItem
                required property var modelData
                implicitWidth: 24
                implicitHeight: 26
                color: "transparent"
                Image { anchors.centerIn: parent; width: 16; height: 16; source: trayItem.modelData.icon }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: event => {
                        if (event.button === Qt.MiddleButton) trayItem.modelData.secondaryActivate();
                        else if (event.button === Qt.RightButton || trayItem.modelData.onlyMenu) {
                            if (trayItem.modelData.hasMenu) trayMenu.open();
                        } else trayItem.modelData.activate();
                    }
                    onWheel: event => trayItem.modelData.scroll(event.angleDelta.y, false)
                }
                QsMenuAnchor {
                    id: trayMenu
                    menu: trayItem.modelData.menu
                    anchor.window: bar
                    anchor.rect.x: trayItem.mapToItem(bar.contentItem, 0, 0).x
                    anchor.rect.y: bar.height
                }
            }
        }
        Chip {
            text: (bar.shell.status.layout ?? "").startsWith("English") ? "US" : (bar.shell.status.layout ?? "").startsWith("Persian") ? "IR" : (bar.shell.status.layout ?? "").slice(0, 3)
            tooltip: bar.shell.status.layout ?? ""
            onClicked: I3.dispatch("input type:keyboard xkb_switch_layout next")
        }
        Chip {
            visible: Settings.notificationsEnabled
            text: (bar.shell.notificationService?.dnd ? "󰂛 " : "󰂚 ") + (bar.shell.notificationService?.items.values.length ?? 0)
            onClicked: bar.shell.toggle("notifications")
        }
        Chip { text: "⏻"; foreground: "#a1c999"; onClicked: bar.shell.toggle("power") }
    }
}
