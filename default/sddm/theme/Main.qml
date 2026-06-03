import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#11111b"

    property string configuredFont: config.font || "Monospace"
    property bool loginFailed: false
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
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 8
                color: "transparent"
                border.width: 2
                border.color: userInput.activeFocus ? "#55cba6f7" : "#33ffffff"

                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
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
            }

            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 8
                color: "transparent"
                border.width: 2
                border.color: root.loginFailed ? "#aaff6633" : (passwordInput.activeFocus ? "#5500ff99" : "#33ffffff")

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "*"
                    color: "#8f8f8f"
                    selectionColor: "#5500ff99"
                    selectedTextColor: "#11111b"
                    font.family: root.configuredFont
                    font.pixelSize: 18
                    clip: true

                    KeyNavigation.tab: userInput

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
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    text: passwordInput.text.length === 0 ? "Enter Password" : ""
                    color: "#8f8f8f"
                    font.family: root.configuredFont
                    font.pixelSize: 18
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                text: root.loginFailed ? "Authentication failed" : ""
                color: "#ff6633"
                font.family: root.configuredFont
                font.pixelSize: 14
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
