pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: card
    required property var notification
    implicitHeight: column.implicitHeight + 24
    radius: 10
    color: "#252733"
    border.color: "#454963"
    ColumnLayout {
        id: column
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
        spacing: 6
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: card.notification.appName
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: "#7a95c9"
                font.family: Settings.fontFamily
                font.pixelSize: 12
            }
            ActionButton { text: "×"; onClicked: card.notification.dismiss() }
        }
        Text {
            Layout.fillWidth: true
            text: card.notification.summary
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            color: "#e5e5e5"
            font.family: Settings.fontFamily
            font.bold: true
        }
        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: card.notification.body
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 6
            elide: Text.ElideRight
            color: "#b7bac0"
            font.family: Settings.fontFamily
        }
        Flow {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: card.notification.actions
                ActionButton {
                    required property var modelData
                    text: modelData.text
                    onClicked: modelData.invoke()
                }
            }
        }
    }
    component ActionButton: Button {
        id: button
        font.family: Settings.fontFamily
        contentItem: Text {
            text: button.text
            font: button.font
            color: "#e5e5e5"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle { color: button.hovered ? "#454963" : "#363a50"; radius: 5 }
    }
}
