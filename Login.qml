import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasma5support 2.0 as PlasmaCore

FocusScope {
    id: root

    // Required properties for compatibility with Main.qml
    property var userListModel
    property bool loginScreenUiVisible: false
    property int userListCurrentIndex: 0
    property string lastUserName: ""
    property bool showUserList: false
    property string notificationMessage: ""
    property list<Item> actionItems

    // Password box reference for Main.qml focus management
    property Item mainPasswordBox: passwordBox

    // We don't need user list prompt but keep it defined
    property bool showUsernamePrompt: true

    signal loginRequest(string username, string password)

    // Scaling helper
    readonly property real scaleVal: height / 92.0

    function startLogin() {
        var username = userNameInput.text
        var password = passwordBox.text
        loginButton.forceActiveFocus()
        loginRequest(username, password)
    }

    // Border and background of the dialog box (matches the retro warnet box style)
    Rectangle {
        anchors.fill: parent
        color: "#30EEEE"        // Cream/light grayish-green matching the original box
        border.color: "#30EEEE" // Bright cyan matching the original box border
        border.width: Math.max(1, Math.round(1 * scaleVal))
        radius: Math.max(2, Math.round(2 * scaleVal))

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.max(3, Math.round(4 * scaleVal))
            spacing: Math.max(2, Math.round(3 * scaleVal))

            // Title Bar (matches the grayish-gold gradient)
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(16, Math.round(18 * scaleVal))
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#DEE2CC" }
                    GradientStop { position: 1.0; color: "#C0BEB0" }
                }
                radius: Math.max(1, Math.round(1 * scaleVal))

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.max(4, Math.round(6 * scaleVal))
                    anchors.right: parent.right
                    anchors.rightMargin: Math.max(4, Math.round(6 * scaleVal))
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.notificationMessage !== "" ? root.notificationMessage : "Login Billing"
                    color: root.notificationMessage !== "" ? "#FF3333" : "#2C2A20" // Dark text for high contrast
                    font.bold: true
                    font.pixelSize: Math.max(9, Math.round(10 * scaleVal))
                    font.family: config.font
                    elide: Text.ElideRight
                }
            }

            // Form Fields
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rowSpacing: Math.max(2, Math.round(3 * scaleVal))
                columnSpacing: Math.max(4, Math.round(6 * scaleVal))

                Text {
                    text: "User:"
                    color: "#3E3C32" // Soft dark gold/gray
                    font.bold: true
                    font.pixelSize: Math.max(8, Math.round(9 * scaleVal))
                    font.family: config.font
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: userNameInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(15, Math.round(18 * scaleVal))
                    font.pixelSize: Math.max(8, Math.round(9 * scaleVal))
                    font.family: config.font
                    color: "#222222"
                    leftPadding: 4
                    rightPadding: 4
                    topPadding: 0
                    bottomPadding: 0
                    text: root.lastUserName
                    focus: !root.lastUserName

                    background: Rectangle {
                        color: "white"
                        border.color: "#AAA899"
                        border.width: 1
                        radius: 1
                    }

                    onAccepted: passwordBox.forceActiveFocus()
                }

                Text {
                    text: "Pass:"
                    color: "#3E3C32"
                    font.bold: true
                    font.pixelSize: Math.max(8, Math.round(9 * scaleVal))
                    font.family: config.font
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: passwordBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(15, Math.round(18 * scaleVal))
                    font.pixelSize: Math.max(8, Math.round(9 * scaleVal))
                    font.family: config.font
                    color: "#222222"
                    echoMode: TextInput.Password
                    leftPadding: 4
                    rightPadding: 4
                    topPadding: 0
                    bottomPadding: 0
                    focus: !!root.lastUserName

                    background: Rectangle {
                        color: "white"
                        border.color: "#AAA899"
                        border.width: 1
                        radius: 1
                    }

                    onAccepted: {
                        if (root.loginScreenUiVisible) {
                            startLogin()
                        }
                    }

                    Connections {
                        target: sddm
                        function onLoginFailed() {
                            passwordBox.selectAll()
                            passwordBox.forceActiveFocus()
                        }
                    }
                }

                // Row for Buttons
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(16, Math.round(18 * scaleVal))
                    spacing: Math.max(4, Math.round(6 * scaleVal))

                    Button {
                        id: loginButton
                        text: "Login"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        enabled: passwordBox.text !== ""

                        contentItem: Text {
                            text: loginButton.text
                            font.pixelSize: Math.max(8, Math.round(9 * scaleVal))
                            font.bold: true
                            color: loginButton.enabled ? "#2C2A20" : "#777777"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: loginButton.enabled ? (loginButton.pressed ? "#8F8E81" : (loginButton.hovered ? "#C0BEB0" : "#AAA899")) : "#D1DCDD"
                            border.color: loginButton.enabled ? "#8F8E81" : "#AAA899"
                            border.width: 1
                            radius: 2
                        }

                        onClicked: startLogin()
                    }

                    Button {
                        id: resetButton
                        text: "Reset"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        contentItem: Text {
                            text: resetButton.text
                            font.pixelSize: Math.max(8, Math.round(9 * scaleVal))
                            font.bold: true
                            color: "#3E3C32"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: resetButton.pressed ? "#C8CABD" : (resetButton.hovered ? "#F0F2E7" : "#E5E7DC")
                            border.color: "#AAA899"
                            border.width: 1
                            radius: 2
                        }

                        onClicked: {
                            userNameInput.text = ""
                            passwordBox.text = ""
                            userNameInput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }
}
