import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent
    focus: true

    property string errorMessage: ""
    property bool isLockedOut: false
    property int lockoutRemaining: 0
    signal closed()

    // Scaling helper based on height
    readonly property real scaleVal: height / 900.0

    // Dark background overlay to dim the screen
    Rectangle {
        anchors.fill: parent
        color: "#80000000" // Semi-transparent black
        
        // Prevent mouse clicks from passing through to the login screen
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: {}
        }
    }

    // Dialog Box
    Rectangle {
        id: dialogBox
        width: Math.max(300, Math.round(350 * scaleVal))
        height: Math.max(130, Math.round(150 * scaleVal))
        anchors.centerIn: parent
        color: "#DEE2CC"        // Cream/light grayish-green matching the theme
        border.color: "#30EEEE" // Bright cyan border
        border.width: Math.max(1, Math.round(2 * scaleVal))
        radius: Math.max(2, Math.round(4 * scaleVal))

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.max(4, Math.round(6 * scaleVal))
            spacing: Math.max(6, Math.round(10 * scaleVal))

            // Title Bar
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(20, Math.round(25 * scaleVal))
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#DEE2CC" }
                    GradientStop { position: 1.0; color: "#C0BEB0" }
                }
                radius: Math.max(1, Math.round(2 * scaleVal))

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.max(6, Math.round(8 * scaleVal))
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Error") // Uses system default localizable "Error"
                    color: "#FF3333"   // Red text for error/warning
                    font.bold: true
                    font.pixelSize: Math.max(10, Math.round(12 * scaleVal))
                    font.family: config.font
                }

                // Close button (X) in the title bar
                Button {
                    id: closeBtn
                    anchors.right: parent.right
                    anchors.rightMargin: Math.max(4, Math.round(6 * scaleVal))
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(14, Math.round(16 * scaleVal))
                    height: Math.max(14, Math.round(16 * scaleVal))
                    enabled: !root.isLockedOut
                    opacity: enabled ? 1.0 : 0.4

                    contentItem: Text {
                        text: "×"
                        font.pixelSize: Math.max(10, Math.round(12 * scaleVal))
                        font.bold: true
                        color: "#2C2A20"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: closeBtn.pressed ? "#8F8E81" : (closeBtn.hovered ? "#C0BEB0" : "#AAA899")
                        border.color: "#8F8E81"
                        border.width: 1
                        radius: 1
                    }

                    onClicked: root.closed()
                }
            }

            // Message Body (Icon + Text)
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Math.max(8, Math.round(12 * scaleVal))
                Layout.rightMargin: Math.max(8, Math.round(12 * scaleVal))
                spacing: Math.max(8, Math.round(12 * scaleVal))

                // Warning Icon: Red circle with white "X"
                Rectangle {
                    width: Math.max(28, Math.round(36 * scaleVal))
                    height: Math.max(28, Math.round(36 * scaleVal))
                    radius: width / 2
                    color: "#FF3333"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "X"
                        color: "white"
                        font.bold: true
                        font.pixelSize: parent.width * 0.5
                    }
                }

                // Message Text
                Text {
                    Layout.fillWidth: true
                    text: root.errorMessage
                    color: "#2C2A20"
                    font.bold: true
                    font.pixelSize: Math.max(9, Math.round(11 * scaleVal))
                    font.family: config.font
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // OK Button
            Button {
                id: okButton
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.max(60, Math.round(80 * scaleVal))
                Layout.preferredHeight: Math.max(20, Math.round(24 * scaleVal))
                Layout.bottomMargin: Math.max(4, Math.round(6 * scaleVal))
                text: root.isLockedOut ? ("Wait (" + root.lockoutRemaining + "s)") : "OK"
                enabled: !root.isLockedOut

                contentItem: Text {
                    text: okButton.text
                    font.pixelSize: Math.max(9, Math.round(11 * scaleVal))
                    font.bold: true
                    color: okButton.enabled ? "#2C2A20" : "#777777"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: okButton.enabled ? (okButton.pressed ? "#8F8E81" : (okButton.hovered ? "#C0BEB0" : "#AAA899")) : "#D1DCDD"
                    border.color: okButton.enabled ? "#8F8E81" : "#AAA899"
                    border.width: 1
                    radius: 2
                }

                onClicked: root.closed()
            }
        }
    }

    // Capture keyboard inputs (Enter, Space, Escape) to close the dialog
    Keys.onPressed: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space || event.key === Qt.Key_Escape) {
            if (!root.isLockedOut) {
                root.closed();
            }
            event.accepted = true;
        }
    }

    // Automatically request focus when visible
    onVisibleChanged: {
        if (visible) {
            if (root.isLockedOut) {
                root.forceActiveFocus();
            } else {
                okButton.forceActiveFocus();
            }
        }
    }
}

