import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: service
    property alias items: server.trackedNotifications
    property bool dnd: false
    property var popupIds: []
    onDndChanged: { if (dnd) popupIds = []; }

    function hidePopup(notification) {
        popupIds = popupIds.filter(id => id !== notification.id);
        if (notification.transient) notification.expire();
    }
    function clear() {
        // Copy before dismissing, since each dismissal changes the model.
        server.trackedNotifications.values.slice().forEach(n => n.dismiss());
    }
    NotificationServer {
        id: server
        actionsSupported: true
        persistenceSupported: true
        bodyMarkupSupported: false
        onNotification: notification => {
            notification.tracked = true;
            if (notification.transient && service.dnd) {
                notification.expire();
                return;
            }
            if (!service.dnd && !notification.lastGeneration) {
                service.popupIds = service.popupIds.filter(id => id !== notification.id).concat([notification.id]);
            }
            const id = notification.id;
            notification.closed.connect(() => { service.popupIds = service.popupIds.filter(value => value !== id); });
            // Bound the in-memory history; it is intentionally not saved to disk.
            const items = server.trackedNotifications.values;
            if (items.length > 100) items[0].dismiss();
        }
    }
}
