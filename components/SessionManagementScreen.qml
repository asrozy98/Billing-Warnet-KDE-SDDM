/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
    SPDX-License-Identifier: LGPL-2.0-or-later
    Modified: Warnet Billing Style — compact top-bar layout
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

FocusScope {
    id: root

    property alias notificationMessage: notificationsLabel.text
    property alias actionItems: actionItemsLayout.children
    property alias actionItemsVisible: actionItemsLayout.visible
    property alias userListModel: userListView.model
    property alias userListCurrentIndex: userListView.currentIndex
    property alias userListCurrentItem: userListView.currentItem
    property bool showUserList: false
    property alias userList: userListView

    property int fontSize: parseInt(config.fontSize) || 10

    default property alias _children: innerLayout.children

    signal userSelected()

    function playHighlightAnimation() {
        bounceAnimation.start()
    }

    // Hidden user list (not used in billing style)
    UserList {
        id: userListView
        visible: false
        model: undefined
        onUserSelected: root.userSelected()
    }

    // ── Compact vertical layout inside the top-right panel ────────────────────
    ColumnLayout {
        id: prompts
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Notification label (caps lock, login failed, etc.)
        PlasmaComponents3.Label {
            id: notificationsLabel
            font.pointSize: root.fontSize - 1
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            color: "#FFD54F"
            visible: text !== ""

            SequentialAnimation {
                id: bounceAnimation
                loops: 1
                PropertyAnimation {
                    target: notificationsLabel
                    properties: "scale"
                    from: 1.0; to: 1.1
                    duration: 120
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation {
                    target: notificationsLabel
                    properties: "scale"
                    from: 1.1; to: 1.0
                    duration: 120
                    easing.type: Easing.InQuad
                }
            }
        }

        // Form inputs and login button
        ColumnLayout {
            id: innerLayout
            Layout.fillWidth: true
            spacing: 4
        }

        // Action buttons (Sleep, Restart, Shutdown, etc.)
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: actionItemsLayout.implicitHeight
            implicitWidth: actionItemsLayout.implicitWidth
            Layout.topMargin: 4

            Row {
                id: actionItemsLayout
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
            }
        }

        Item { Layout.fillHeight: true }
    }
}
