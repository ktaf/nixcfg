pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Wayland

PanelWindow {
    id: popups
    required property var shell
    required property var targetScreen
    screen: targetScreen
    property var service: shell.notificationService
    property var notifications: service ? service.items.values.filter(n => service.popupIds.includes(n.id)).slice(-3) : []
    visible: notifications.length > 0 && (I3.focusedMonitor?.name ?? Quickshell.screens[0]?.name) === targetScreen.name
    anchors { top: true; right: true }
    margins { top: Settings.barHeight + 10; right: 10 }
    implicitWidth: 400
    implicitHeight: column.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    color: "transparent"

    Column {
        id: column
        width: parent.width
        spacing: 8
        Repeater {
            model: popups.notifications
            NotificationCard {
                id: toast
                required property var modelData
                notification: modelData
                width: column.width
                Timer {
                    // Quickshell exposes expireTimeout in seconds. 0 means persistent.
                    interval: Math.max(1, toast.notification.expireTimeout > 0 ? toast.notification.expireTimeout * 1000 : 6000)
                    running: toast.notification.expireTimeout !== 0
                    onTriggered: popups.service?.hidePopup(toast.notification)
                }
            }
        }
    }
}
