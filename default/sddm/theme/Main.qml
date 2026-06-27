import QtQuick 2.15
import QtQuick.Layouts 1.15

// qmllint disable unqualified

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#11111b"

    property string configuredFont: config.font || "Monospace"
    property bool loginFailed: false
    property bool passwordVisible: false
    property date now: new Date()
    property int sessionIndex: {
        for (var i = 0; i < sessionModel.rowCount(); i++) {
            var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString().toLowerCase()
            if (name.indexOf("kitana") !== -1 || name.indexOf("hypr") !== -1)
                return i
        }
        return sessionModel.lastIndex
    }

    function submitLogin() {
        if (userInput.text.length === 0)
            return

        sddm.login(userInput.text, passwordInput.text, root.sessionIndex)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.loginFailed = true
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
            failureShake.restart()
        }

        function onLoginSucceeded() {
            root.loginFailed = false
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Image {
        anchors.fill: parent
        source: config.background || "background"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: "#aa11111b"
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.72, 520)
        spacing: 28

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(root.now, "hh:mm")
            color: "#cdd6f4"
            font.family: root.configuredFont
            font.pixelSize: Math.max(52, Math.min(root.width, root.height) * 0.072)
            font.weight: Font.Light
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(root.now, "dddd, dd MMMM yyyy")
            color: "#a6adc8"
            font.family: root.configuredFont
            font.pixelSize: 18
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 28
            spacing: 12

            Rectangle {
                id: userField

                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: height / 2
                color: userInput.activeFocus ? "#66798aa6" : "#5570809c"
                border.width: 0

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    source: "icons/user.svg"
                    sourceSize.width: width
                    sourceSize.height: height
                    opacity: userInput.activeFocus ? 0.92 : 0.72
                }

                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 60
                    anchors.rightMargin: 24
                    verticalAlignment: TextInput.AlignVCenter
                    text: userModel.lastUser
                    selectByMouse: true
                    color: "#cdd6f4"
                    selectionColor: "#55cba6f7"
                    selectedTextColor: "#11111b"
                    font.family: root.configuredFont
                    font.pixelSize: 18
                    clip: true

                    KeyNavigation.tab: passwordInput

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            passwordInput.forceActiveFocus()
                            event.accepted = true
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 60
                    anchors.verticalCenter: parent.verticalCenter
                    text: userInput.text.length === 0 ? "Enter Username" : ""
                    color: "#b8c1d8"
                    font.family: root.configuredFont
                    font.pixelSize: 18
                }
            }

            Rectangle {
                id: passwordField

                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: height / 2
                color: root.loginFailed ? "#8a8c4a52" : (passwordInput.activeFocus ? "#66798aa6" : "#5570809c")
                border.width: 0

                transform: Translate {
                    id: passwordShake
                }

                Image {
                    id: passwordIcon

                    z: 1
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    source: root.passwordVisible ? "icons/eye-off.svg" : "icons/eye.svg"
                    sourceSize.width: width
                    sourceSize.height: height
                    opacity: passwordMouse.containsMouse || passwordInput.activeFocus ? 0.92 : 0.72
                }

                MouseArea {
                    id: passwordMouse

                    z: 2
                    anchors.centerIn: passwordIcon
                    width: 42
                    height: 42
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.passwordVisible = !root.passwordVisible
                        passwordInput.forceActiveFocus()
                    }
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 60
                    anchors.rightMargin: 24
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: root.passwordVisible ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "*"
                    color: "#f2f5ff"
                    selectionColor: "#5500ff99"
                    selectedTextColor: "#11111b"
                    font.family: root.configuredFont
                    font.pixelSize: 18
                    clip: true

                    KeyNavigation.tab: suspendButton.enabled ? suspendButton : (hibernateButton.enabled ? hibernateButton : rebootButton)

                    onTextChanged: root.loginFailed = false


                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.submitLogin()
                            event.accepted = true
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 60
                    anchors.verticalCenter: parent.verticalCenter
                    text: passwordInput.text.length === 0 ? "Enter Password" : ""
                    color: "#b8c1d8"
                    font.family: root.configuredFont
                    font.pixelSize: 18
                }
            }

            SequentialAnimation {
                id: failureShake

                NumberAnimation { target: passwordShake; property: "x"; to: -8; duration: 45 }
                NumberAnimation { target: passwordShake; property: "x"; to: 8; duration: 70 }
                NumberAnimation { target: passwordShake; property: "x"; to: -5; duration: 60 }
                NumberAnimation { target: passwordShake; property: "x"; to: 0; duration: 60 }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                text: root.loginFailed ? "Authentication failed" : ""
                color: "#ffb1a3"
                font.family: root.configuredFont
                font.pixelSize: 14
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 6
                spacing: 8

                SystemAction {
                    id: suspendButton

                    iconSource: "icons/suspend.svg"
                    available: sddm.canSuspend
                    KeyNavigation.tab: hibernateButton.enabled ? hibernateButton : rebootButton
                    KeyNavigation.backtab: passwordInput
                    onTriggered: sddm.suspend()
                }

                SystemAction {
                    id: hibernateButton

                    iconSource: "icons/hibernate.svg"
                    available: sddm.canHibernate
                    KeyNavigation.tab: rebootButton
                    KeyNavigation.backtab: suspendButton.enabled ? suspendButton : passwordInput
                    onTriggered: sddm.hibernate()
                }

                SystemAction {
                    id: rebootButton

                    iconSource: "icons/reboot.svg"
                    KeyNavigation.tab: shutdownButton
                    KeyNavigation.backtab: hibernateButton.enabled ? hibernateButton : (suspendButton.enabled ? suspendButton : passwordInput)
                    onTriggered: sddm.reboot()
                }

                SystemAction {
                    id: shutdownButton

                    iconSource: "icons/power.svg"
                    KeyNavigation.tab: userInput
                    KeyNavigation.backtab: rebootButton
                    onTriggered: sddm.powerOff()
                }
            }
        }
    }

    // Subtle icon-only greeter power action button
    component SystemAction: Rectangle {
        id: actionRoot

        property string iconSource: ""
        property bool available: true

        signal triggered

        Layout.preferredWidth: 38
        Layout.preferredHeight: 34
        enabled: available
        activeFocusOnTab: enabled
        radius: height / 2
        color: !enabled ? "#1870809c" : (activeFocus || actionMouse.containsMouse ? "#3f7c8ca6" : "#2870809c")
        border.width: 0
        opacity: enabled ? 1 : 0.42

        Image {
            anchors.centerIn: parent
            width: 15
            height: 15
            source: actionRoot.iconSource
            sourceSize.width: width
            sourceSize.height: height
            opacity: actionRoot.enabled ? 0.82 : 0.7
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            enabled: actionRoot.enabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: actionRoot.triggered()
        }

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                actionRoot.triggered()
                event.accepted = true
            }
        }
    }

    Component.onCompleted: {
        if (userInput.text.length > 0)
            passwordInput.forceActiveFocus()
        else
            userInput.forceActiveFocus()
    }
}
