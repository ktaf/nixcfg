pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: menu
    required property var shell
    property var clips: []
    property string pendingAction: ""
    property var entries: {
        const query = search.text.toLowerCase();
        if (shell.panel === "clipboard") return clips.filter(c => c.label.toLowerCase().includes(query));
        return DesktopEntries.applications.values.filter(e =>
            (e.name + " " + e.genericName + " " + e.comment).toLowerCase().includes(query)
        ).sort((a, b) => a.name.localeCompare(b.name));
    }
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "#88000000"

    onVisibleChanged: {
        if (!visible) return;
        search.text = "";
        pendingAction = "";
        if (shell.panel === "clipboard") clipboardProcess.running = true;
        Qt.callLater(() => search.visible ? search.forceActiveFocus() : content.forceActiveFocus());
    }

    function activateEntry(index) {
        const entry = entries[index];
        if (!entry) return;
        if (shell.panel === "clipboard") shell.run(Settings.commands.paste.concat([entry.id]));
        else entry.execute();
        shell.panel = "";
    }
    function power(action) {
        if (["shutdown", "reboot", "logout"].includes(action) && pendingAction !== action) {
            pendingAction = action;
            return;
        }
        shell.run(Settings.commands[action]);
        shell.panel = "";
    }
    Process {
        id: clipboardProcess
        command: Settings.commands.clipboard
        stdout: StdioCollector {
            onStreamFinished: {
                try { menu.clips = JSON.parse(text); }
                catch (error) { menu.clips = []; console.warn("Clipboard:", error); }
            }
        }
    }

    MouseArea { anchors.fill: parent; onClicked: menu.shell.panel = "" }
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(640, menu.width - 40)
        height: Math.min(620, menu.height - 80)
        color: "#1a1b26"
        radius: 14
        border.color: "#454963"
        MouseArea { anchors.fill: parent } // Keep clicks inside the menu from reaching the backdrop.

        FocusScope {
            id: content
            anchors.fill: parent
            anchors.margins: 20
            focus: true
            Keys.onEscapePressed: menu.shell.panel = ""

            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    Heading {
                        Layout.fillWidth: true
                        text: ({launcher: "Applications", clipboard: "Clipboard", notifications: "Notifications", settings: "Quick settings", power: "Session"})[menu.shell.panel] ?? ""
                    }
                    MenuButton { text: "Close · Esc"; onClicked: menu.shell.panel = "" }
                }
                TextField {
                    id: search
                    Layout.fillWidth: true
                    visible: ["launcher", "clipboard"].includes(menu.shell.panel)
                    placeholderText: menu.shell.panel === "clipboard" ? "Search clipboard history…" : "Search applications…"
                    font.family: Settings.fontFamily
                    color: "#e5e5e5"
                    background: Rectangle { color: "#252733"; radius: 6; border.color: "#454963" }
                    onTextChanged: entryList.currentIndex = 0
                    onAccepted: menu.activateEntry(entryList.currentIndex)
                    Keys.onDownPressed: entryList.currentIndex = Math.min(entryList.count - 1, entryList.currentIndex + 1)
                    Keys.onUpPressed: entryList.currentIndex = Math.max(0, entryList.currentIndex - 1)
                    Keys.onEscapePressed: menu.shell.panel = ""
                }
                ListView {
                    id: entryList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: search.visible
                    clip: true
                    model: menu.entries
                    spacing: 4
                    currentIndex: 0
                    ScrollBar.vertical: ScrollBar { }
                    delegate: MenuButton {
                        required property var modelData
                        required property int index
                        width: entryList.width
                        text: menu.shell.panel === "clipboard" ? modelData.label : modelData.name
                        highlighted: ListView.isCurrentItem
                        onClicked: menu.activateEntry(index)
                    }
                    Label {
                        anchors.centerIn: parent
                        visible: entryList.count === 0
                        text: menu.shell.panel === "clipboard" ? "No clipboard entries" : "No matching applications"
                        color: "#b7bac0"
                        font.family: Settings.fontFamily
                    }
                }

                ColumnLayout {
                    visible: menu.shell.panel === "notifications"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        MenuButton {
                            text: menu.shell.notificationService?.dnd ? "Do not disturb: on" : "Do not disturb: off"
                            onClicked: {
                                const service = menu.shell.notificationService;
                                if (service) service.dnd = !service.dnd;
                            }
                        }
                        MenuButton { text: "Clear all"; onClicked: menu.shell.notificationService?.clear() }
                    }
                    ListView {
                        id: notificationList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: menu.shell.notificationService?.items ?? null
                        ScrollBar.vertical: ScrollBar { }
                        delegate: NotificationCard {
                            required property var modelData
                            notification: modelData
                            width: notificationList.width
                        }
                        Label {
                            anchors.centerIn: parent
                            visible: notificationList.count === 0
                            text: "No notifications"
                            color: "#b7bac0"
                            font.family: Settings.fontFamily
                        }
                    }
                }

                ColumnLayout {
                    visible: menu.shell.panel === "settings"
                    Layout.fillWidth: true
                    spacing: 12
                    Detail { text: menu.shell.status.network ?? "Network unavailable"; Layout.fillWidth: true }
                    RowLayout {
                        MenuButton {
                            text: menu.shell.status.wifi ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
                            onClicked: menu.shell.run(menu.shell.status.wifi ? Settings.commands.wifiOff : Settings.commands.wifiOn)
                        }
                        MenuButton { text: "Connections…"; onClicked: { menu.shell.run(Settings.commands.network); menu.shell.panel = ""; } }
                    }
                    RowLayout {
                        MenuButton {
                            text: menu.shell.status.bluetooth ? "Turn Bluetooth off" : "Turn Bluetooth on"
                            onClicked: menu.shell.run(menu.shell.status.bluetooth ? Settings.commands.bluetoothOff : Settings.commands.bluetoothOn)
                        }
                        MenuButton { text: "Bluetooth devices…"; onClicked: { menu.shell.run(Settings.commands.bluetooth); menu.shell.panel = ""; } }
                    }
                    Detail { text: "Volume: " + (menu.shell.status.muted ? "muted" : (menu.shell.status.volume ?? "unavailable") + "%") }
                    RowLayout {
                        MenuButton { text: "−"; onClicked: menu.shell.run(Settings.commands.volumeDown) }
                        MenuButton { text: "Mute"; onClicked: menu.shell.run(Settings.commands.mute) }
                        MenuButton { text: "+"; onClicked: menu.shell.run(Settings.commands.volumeUp) }
                        MenuButton { text: "Audio devices…"; onClicked: { menu.shell.run(Settings.commands.mixer); menu.shell.panel = ""; } }
                    }
                    RowLayout {
                        visible: menu.shell.status.brightness != null
                        Detail { text: "Brightness: " + menu.shell.status.brightness + "%" }
                        MenuButton { text: "−"; onClicked: menu.shell.run(Settings.commands.brightnessDown) }
                        MenuButton { text: "+"; onClicked: menu.shell.run(Settings.commands.brightnessUp) }
                    }
                    Detail { text: "CPU " + (menu.shell.status.cpu ?? "–") + "%  ·  RAM " + (menu.shell.status.memory ?? "–") + "%  ·  Disk " + (menu.shell.status.disk ?? "–") + "%" }
                    Detail { visible: menu.shell.status.temperature != null; text: "Temperature: " + menu.shell.status.temperature + "°C" }
                }

                ColumnLayout {
                    visible: menu.shell.panel === "power"
                    Layout.fillWidth: true
                    spacing: 10
                    Repeater {
                        model: [
                            {action: "lock", title: "Lock screen"},
                            {action: "suspend", title: "Lock and suspend"},
                            {action: "logout", title: "Log out of Sway"},
                            {action: "reboot", title: "Restart"},
                            {action: "shutdown", title: "Shut down"}
                        ]
                        MenuButton {
                            required property var modelData
                            Layout.fillWidth: true
                            text: (menu.pendingAction === modelData.action ? "Confirm: " : "") + modelData.title
                            onClicked: menu.power(modelData.action)
                        }
                    }
                    Detail { text: "Log out, restart, and shut down require a second click."; Layout.fillWidth: true }
                }
                Item { Layout.fillHeight: true; visible: ["settings", "power"].includes(menu.shell.panel) }
            }
        }
    }

    component Heading: Text {
        color: "#e5e5e5"
        font.family: Settings.fontFamily
        font.pixelSize: 20
        font.bold: true
    }
    component Detail: Text {
        color: "#b7bac0"
        font.family: Settings.fontFamily
        font.pixelSize: 13
        wrapMode: Text.Wrap
        textFormat: Text.PlainText
    }
    component MenuButton: Button {
        id: button
        font.family: Settings.fontFamily
        implicitHeight: 38
        contentItem: Text {
            text: button.text
            font: button.font
            color: button.highlighted ? "#ecd3a0" : "#e5e5e5"
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
        }
        background: Rectangle {
            color: button.hovered || button.highlighted ? "#454963" : "#252733"
            radius: 6
        }
    }
}
