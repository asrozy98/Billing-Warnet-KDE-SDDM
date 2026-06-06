import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

TextField {
    placeholderTextColor: "#aaccee"
    palette.text: "#ffffff"
    font.pointSize: config.fontSize
    font.family: config.font
    width: parent.width
    leftPadding: 10
    rightPadding: 10

    background: Rectangle {
        color: "#1A3A5C"
        opacity: 0.85
        radius: 4
        border.width: 1
        border.color: "#0288D1"
        anchors.fill: parent
    }
}