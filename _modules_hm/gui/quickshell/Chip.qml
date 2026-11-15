import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string text: ""
    property string tooltip: ""
    property color foreground: "#e5e5e5"
    property bool selected: false
    property int maximumWidth: 10000
    signal clicked()
    signal rightClicked()
    signal scrolled(bool up)
    implicitWidth: Math.min(maximumWidth, label.implicitWidth + 16)
    implicitHeight: 26
    radius: 7
    color: selected ? "#454963" : mouse.containsMouse ? "#363a50" : "#252733"
    Text {
        id: label
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: root.foreground
        font.family: Settings.fontFamily
        font.pixelSize: 13
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => event.button === Qt.RightButton ? root.rightClicked() : root.clicked()
        onWheel: event => root.scrolled(event.angleDelta.y > 0)
    }
    ToolTip.visible: mouse.containsMouse && root.tooltip !== ""
    ToolTip.text: root.tooltip
    ToolTip.delay: 500
}
