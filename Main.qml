/*
 *   Theme: Dolphin Billing Warnet
 *   Author: M Faisal A
 *   Source: https://github.com/asrozy98/Billing-Warnet-KDE-SDDM
 *   Based on Sweet-Mars-Plasma6 SDDM theme
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasma5support 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.keyboardlayout as Keyboards

import Qt5Compat.GraphicalEffects
import org.kde.kirigami 2.20 as Kirigami

import org.kde.breeze.components
import "components"

Item {
    id: root

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    width: 1600
    height: 900

    property string notificationMessage

    property int failedAttempts: 0
    property int lockoutRemaining: 0
    readonly property bool isLockedOut: lockoutRemaining > 0
    readonly property int maxFailedAttempts: parseInt(config.lockoutAttempts) || 3
    readonly property int lockoutDuration: parseInt(config.lockoutDuration) || 600 // 10 menit (600 detik) bawaan OS

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    // ─── Background (full screen, clean wallpaper) ─────────────────────────
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "assets/bg.jpg"
        fillMode: Image.Stretch
        asynchronous: true
        cache: true
    }

    // ─── Branding Header Image (billing.png) ──────────────────────────────────
    // Placed right next to the login box (scaled proportionally)
    Image {
        id: brandingImage
        source: "assets/billing.png"
        x: scaledBox1X + scaledBox1W + Math.round(15 * scaleX)
        y: scaledBox1Y
        width: scaledBox1H * (907 / 291) // Maintain aspect ratio based on height
        height: scaledBox1H
        fillMode: Image.Stretch
        asynchronous: true
        cache: true
        z: 10

        // Digital Clock positioned precisely in the solid blue box of billing.png
        // Digital Clock & Date positioned precisely in the solid blue box of billing.png
        Column {
            id: clockColumn
            x: brandingImage.width * 0.735
            y: brandingImage.height * 0.02
            width: brandingImage.width * 0.25
            spacing: 2
            
            Text {
                id: dateText
                width: parent.width
                text: Qt.formatDate(new Date(), "dddd, d\nMMMM yyyy")
                color: "#FFFFFF"
                font.family: "Monospace"
                font.pixelSize: Math.max(7, Math.round(brandingImage.height * 0.10))
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            Text {
                id: timeText
                width: parent.width
                text: Qt.formatTime(new Date(), "hh:mm:ss")
                color: "#FFFFFF"
                font.bold: true
                font.family: "Monospace"
                font.pixelSize: Math.max(8, Math.round(brandingImage.height * 0.14))
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                var d = new Date();
                dateText.text = Qt.formatDate(d, "dddd, d\nMMMM yyyy")
                timeText.text = Qt.formatTime(d, "hh:mm:ss")
            }
        }
    }

    // ─── Coordinates mapping for top-left box overlay ──────────────────────────
    // The background image is 1024x576. 
    // box1 is at x=7, y=7, w=203, h=83 on the 1024x576 image.
    readonly property real srcW: 1024
    readonly property real srcH: 576
    readonly property real scaleX: root.width / srcW
    readonly property real scaleY: root.height / srcH

    readonly property real box1X: 5
    readonly property real box1Y: 12
    readonly property real box1W: 208
    readonly property real box1H: 92

    readonly property real scaledBox1X: box1X * scaleX
    readonly property real scaledBox1Y: box1Y * scaleY
    readonly property real scaledBox1W: box1W * scaleX
    readonly property real scaledBox1H: box1H * scaleY

    // ─── Mouse / Key Interaction ──────────────────────────────────────────────
    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent

        property bool uiVisible: true
        property bool blockUI: userListComponent.mainPasswordBox.text.length > 0 ||
                               Keyboards.KWinVirtualKeyboard.visible || config.type != "image"

        hoverEnabled: true
        drag.filterChildren: true
        onPressed:        uiVisible = true
        onPositionChanged: uiVisible = true
        onUiVisibleChanged: {
            if (blockUI) fadeoutTimer.running = false
            else if (uiVisible) fadeoutTimer.restart()
        }
        onBlockUIChanged: {
            if (blockUI) { fadeoutTimer.running = false; uiVisible = true }
            else fadeoutTimer.restart()
        }
        Keys.onPressed: function(event) { uiVisible = true; event.accepted = false }

        Timer {
            id: fadeoutTimer
            running: true
            interval: 60000
            onTriggered: { if (!loginScreenRoot.blockUI) loginScreenRoot.uiVisible = false }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // Form Login (overlayed exactly on the top-left box)
        // ═══════════════════════════════════════════════════════════════════════

        // Digital Clock positioned precisely on the solid blue box region of the background image
        // Scaled dynamically relative to root.width and root.height for absolute precision on any resolution
        // (Removed in favor of integrated clock in brandingImage)
        
        StackView {
            id: mainStack
            x: scaledBox1X
            y: scaledBox1Y
            width: scaledBox1W
            height: scaledBox1H
            z: 10
            focus: true

            Timer {
                running: true; repeat: false; interval: 200
                onTriggered: mainStack.forceActiveFocus()
            }

            initialItem: Login {
                id: userListComponent
                userListModel: userModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                showUserList: false

                notificationMessage: {
                    var text = ""
                    // data belum siap saat pertama render → jangan TypeError
                    var caps = keystateSource.data["Caps Lock"] || {}
                    if (caps["Locked"]) {
                        text += i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on")
                        if (root.notificationMessage) text += " • "
                    }
                    text += root.notificationMessage
                    return text
                }

                actionItems: []

                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }
            }

            Behavior on opacity { OpacityAnimator { duration: 250 } }
        }

        // ─── Footer (Sleep / Restart / Shutdown + Session + Keyboard) ─────────
        RowLayout {
            id: footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                margins: 8
            }
            Behavior on opacity { OpacityAnimator { duration: 250 } }

            ActionButton {
                iconSource: Qt.resolvedUrl("assets/suspend.svg")
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep")
                onClicked: sddm.suspend()
                enabled: sddm.canSuspend
                visible: !Keyboards.KWinVirtualKeyboard.visible
            }
            ActionButton {
                iconSource: Qt.resolvedUrl("assets/restart.svg")
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                onClicked: sddm.reboot()
                enabled: sddm.canReboot
                visible: !Keyboards.KWinVirtualKeyboard.visible
            }
            ActionButton {
                iconSource: Qt.resolvedUrl("assets/shutdown.svg")
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                onClicked: sddm.powerOff()
                enabled: sddm.canPowerOff
                visible: !Keyboards.KWinVirtualKeyboard.visible
            }

            PlasmaComponents.ToolButton {
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel",
                             "Button to show/hide virtual keyboard", "Virtual Keyboard")
                font.pointSize: config.fontSize
                icon.name: Keyboards.KWinVirtualKeyboard.visible
                           ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
                onClicked: {
                    if (Keyboards.KWinVirtualKeyboard.visible) {
                        Keyboards.KWinVirtualKeyboard.active = false
                    } else {
                        // fokuskan password dulu, keystroke OSK bisa "dimakan" kalau tidak
                        userListComponent.mainPasswordBox.forceActiveFocus()
                        Keyboards.KWinVirtualKeyboard.forceActivate()
                    }
                }
            }

            KeyboardButton {}
            SessionButton { id: sessionButton }
        }
    }

    // ─── Timer Lockout ────────────────────────────────────────────────────────
    Timer {
        id: lockoutTimer
        interval: 1000
        repeat: true
        running: root.isLockedOut
        onTriggered: {
            if (root.lockoutRemaining > 0) {
                root.lockoutRemaining--
                if (root.lockoutRemaining === 0) {
                    root.failedAttempts = 0
                }
            }
        }
    }

    // ─── Connections ──────────────────────────────────────────────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            if (root.isLockedOut) {
                return
            }
            root.failedAttempts++
            if (root.failedAttempts >= root.maxFailedAttempts) {
                root.lockoutRemaining = root.lockoutDuration
                root.notificationMessage = "Too many failed login attempts."
            } else {
                root.notificationMessage = "Login Failed"
            }
        }
        function onLoginSucceeded() {
            mainStack.opacity = 0
            footer.opacity    = 0
        }
    }

    ErrorDialog {
        id: errorDialog
        anchors.fill: parent
        visible: root.notificationMessage !== ""
        isLockedOut: root.isLockedOut
        lockoutRemaining: root.lockoutRemaining
        errorMessage: root.isLockedOut
                      ? ("Too many failed login attempts. System locked. Please wait " + root.lockoutRemaining + " seconds.")
                      : root.notificationMessage
        z: 100
        onClosed: {
            root.notificationMessage = ""
            // defer focus until the dialog is really hidden, otherwise its focus:true wins
            Qt.callLater(function() {
                userListComponent.mainPasswordBox.forceActiveFocus()
                userListComponent.mainPasswordBox.selectAll()
            })
        }
    }
}
