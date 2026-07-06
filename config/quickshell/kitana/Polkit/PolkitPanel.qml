// Kitana managed Quickshell Polkit prompt

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets as QW
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom
import "../Services" as Services

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings {
        id: settings
    }

    property var panelScreen: null
    property bool submitting: false
    property bool detailsExpanded: false
    property real detailsProgress: detailsExpanded && hasDetails ? 1 : 0
    readonly property var flow: Services.PolkitService.flow
    readonly property bool panelVisible: Services.PolkitService.enabled && Services.PolkitService.active && flow !== null
    readonly property bool responseRequired: flow !== null && flow.isResponseRequired
    readonly property bool responseVisible: flow !== null && flow.responseVisible
    readonly property bool canSubmit: responseRequired && !submitting && responseInput.text.length > 0
    readonly property string fallbackUserName: Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""
    readonly property string authUserName: identityLabel(flow !== null ? flow.selectedIdentity : null) || fallbackUserName
    readonly property string messageText: displayMessage()
    readonly property string inputPromptText: flow !== null && flow.inputPrompt.length > 0 ? flow.inputPrompt : qsTr("Password")
    readonly property string supplementaryText: flow !== null ? flow.supplementaryMessage : ""
    readonly property string actionText: flow !== null ? flow.actionId : ""
    readonly property string identityText: identitySummary()
    readonly property bool hasDetails: identityText.length > 0 || actionText.length > 0
    readonly property string iconSource: flow !== null && flow.iconName.length > 0 ? (Quickshell.iconPath(flow.iconName, true) || "") : ""

    screen: panelScreen
    visible: panelVisible
    focusable: true
    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-blurred-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    onFlowChanged: resetForFlow()
    onPanelVisibleChanged: {
        if (panelVisible)
            Qt.callLater(() => root.focusResponse());
        else {
            detailsExpanded = false;
            resetSecrets();
        }
    }

    Behavior on detailsProgress {
        NumberAnimation {
            duration: 170
            easing.type: Easing.OutCubic
        }
    }

    function identityLabel(identity: var): string {
        if (!identity)
            return "";

        try {
            const user = identity.userName || identity.username || identity.name;
            if (user && String(user).length > 0)
                return cleanIdentityLabel(String(user));
        } catch (error) {
        }

        const label = String(identity);
        if (label.length === 0 || label === "[object Object]" || /^qs::service::polkit::Identity\(/.test(label))
            return "";
        return cleanIdentityLabel(label);
    }

    function cleanIdentityLabel(label: string): string {
        return String(label || "")
            .replace(/^unix-user:/, "")
            .replace(/^unix-group:/, "group ");
    }

    function displayMessage(): string {
        const baseMessage = flow !== null && flow.message.length > 0 ? flow.message : qsTr("Authentication is required");
        const userName = authUserName;
        if (userName.length === 0)
            return baseMessage.replace(/\bas unix-user:([A-Za-z0-9_.-]+)/g, "as $1");

        return baseMessage
            .replace(/\bas unix-user:([A-Za-z0-9_.-]+)/g, "as " + userName)
            .replace(/\bas the super user\b/g, "as " + userName);
    }

    function identitySummary(): string {
        if (flow === null || !flow.identities)
            return "";

        const count = flow.identities.length;
        if (count <= 0)
            return "";

        const label = identityLabel(flow.selectedIdentity);
        if (label.length > 0)
            return count > 1 ? qsTr("%1 (%2 available)").arg(label).arg(count) : label;
        if (fallbackUserName.length > 0)
            return count > 1 ? qsTr("%1 (%2 available)").arg(fallbackUserName).arg(count) : fallbackUserName;
        return count === 1 ? qsTr("1 identity available") : qsTr("%1 identities available").arg(count);
    }

    function resetSecrets(): void {
        submitting = false;
        submitGuard.stop();
        responseInput.text = "";
    }

    function resetForFlow(): void {
        detailsExpanded = false;
        resetSecrets();
        if (panelVisible)
            Qt.callLater(() => root.focusResponse());
    }

    function focusResponse(): void {
        if (panelVisible && responseRequired)
            responseInput.forceActiveFocus();
        else
            overlay.forceActiveFocus();
    }

    function cancelRequest(): void {
        const activeFlow = flow;
        resetSecrets();
        if (activeFlow !== null && !activeFlow.isCompleted)
            activeFlow.cancelAuthenticationRequest();
    }

    function submitResponse(): void {
        const activeFlow = flow;
        if (activeFlow === null || !responseRequired || submitting || responseInput.text.length === 0)
            return;

        const response = responseInput.text;
        responseInput.text = "";
        submitting = true;
        activeFlow.submit(response);
        submitGuard.restart();
    }

    function handleFailure(): void {
        resetSecrets();
        if (panelVisible)
            Qt.callLater(() => root.focusResponse());
    }

    // Flow lifecycle hooks clear sensitive input as conversations change.
    Connections {
        target: root.flow

        function onAuthenticationSucceeded(): void {
            root.resetSecrets();
        }

        function onAuthenticationFailed(): void {
            root.handleFailure();
        }

        function onAuthenticationRequestCancelled(): void {
            root.resetSecrets();
        }

        function onFailedChanged(): void {
            if (root.flow !== null && root.flow.failed)
                root.handleFailure();
        }

        function onInputPromptChanged(): void {
            root.resetForFlow();
        }

        function onResponseVisibleChanged(): void {
            root.resetForFlow();
        }

        function onIsResponseRequiredChanged(): void {
            root.resetForFlow();
        }

        function onSupplementaryMessageChanged(): void {
            if (root.flow !== null && root.flow.supplementaryIsError)
                root.handleFailure();
        }

        function onIsCompletedChanged(): void {
            if (root.flow !== null && root.flow.isCompleted)
                root.resetSecrets();
        }
    }

    Timer {
        id: submitGuard

        interval: 2500
        onTriggered: {
            if (root.panelVisible && root.flow !== null && !root.flow.isCompleted) {
                root.submitting = false;
                root.focusResponse();
            }
        }
    }

    // Full-screen auth guard; background clicks refocus instead of dismissing.
    FocusScope {
        id: overlay

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.cancelRequest()

        Controls.BlurredBackdrop {
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.focusResponse()
        }

        // Authentication request card
        Rectangle {
            id: card

            width: Math.min(560, Math.max(280, parent.width - 32))
            height: content.implicitHeight + 36
            anchors.centerIn: parent
            radius: 18
            color: Colors.bgPrimary
            border.color: Colors.borderFaint
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => mouse.accepted = true
            }

            // Polkit prompt content
            ColumnLayout {
                id: content

                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Prompt header and cancel affordance
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: 14
                        color: Colors.subtleAccent

                        QW.IconImage {
                            id: flowIcon

                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            implicitSize: 22
                            source: root.iconSource
                            visible: root.iconSource.length > 0 && status === Image.Ready
                            asynchronous: true
                            mipmap: true
                        }

                        Controls.Icon {
                            anchors.centerIn: parent
                            visible: !flowIcon.visible
                            name: "power.lock"
                            tone: "accent"
                            size: settings.iconPixelSize + 5
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Authentication Required")
                            color: Colors.fgPrimary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 4
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.messageText
                            color: Colors.fgSecondary
                            wrapMode: Text.WordWrap
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 1
                        }
                    }

                    Controls.CloseButton {
                        Layout.alignment: Qt.AlignTop
                        onClicked: root.cancelRequest()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.supplementaryText.length > 0 || (root.flow !== null && root.flow.failed)
                    text: root.supplementaryText.length > 0 ? root.supplementaryText : qsTr("Authentication failed")
                    color: root.flow !== null && (root.flow.supplementaryIsError || root.flow.failed) ? Colors.error : Colors.fgSecondary
                    wrapMode: Text.WordWrap
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }

                Controls.InputField {
                    id: responseInput

                    Layout.fillWidth: true
                    visible: root.responseRequired
                    iconName: "power.lock"
                    placeholderText: root.inputPromptText
                    echoMode: root.responseVisible ? TextInput.Normal : TextInput.Password
                    inputMethodHints: root.responseVisible ? Qt.ImhNone : (Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase)
                    onAccepted: root.submitResponse()
                    onEscaped: root.cancelRequest()
                }

                Text {
                    Layout.fillWidth: true
                    visible: !root.responseRequired
                    text: qsTr("Waiting for authentication response...")
                    color: Colors.fgSecondary
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }

                // Auth action buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    AuthButton {
                        label: qsTr("Cancel")
                        onClicked: root.cancelRequest()
                    }

                    AuthButton {
                        label: root.submitting ? qsTr("Checking...") : qsTr("Authorize")
                        primary: true
                        enabled: root.canSubmit
                        onClicked: root.submitResponse()
                    }
                }

                // Muted technical detail footer.
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: detailsFooter.implicitWidth + 12
                    Layout.preferredHeight: 22
                    visible: root.hasDetails
                    opacity: detailsMouse.containsMouse ? 0.95 : 0.7

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 110
                            easing.type: Easing.OutCubic
                        }
                    }

                    RowLayout {
                        id: detailsFooter

                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: qsTr("Details")
                            color: Colors.fgMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 2
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Controls.Icon {
                            name: root.detailsExpanded ? "ui.chevron.up" : "ui.chevron.down"
                            tone: "muted"
                            size: 13
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: detailsMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.detailsExpanded = !root.detailsExpanded
                    }
                }

                // Animated request detail reveal.
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: detailsContent.implicitHeight * root.detailsProgress
                    visible: root.hasDetails && (root.detailsExpanded || root.detailsProgress > 0.01)
                    opacity: root.detailsProgress
                    clip: true

                    ColumnLayout {
                        id: detailsContent

                        width: parent.width
                        y: (root.detailsProgress - 1) * 6
                        spacing: 5

                        DetailRow {
                            label: qsTr("Identity")
                            value: root.identityText
                            visible: value.length > 0
                        }

                        DetailRow {
                            label: qsTr("Action")
                            value: root.actionText
                            visible: value.length > 0
                        }
                    }
                }
            }
        }
    }

    component DetailRow: RowLayout {
        id: detail

        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.preferredWidth: 64
            text: detail.label
            color: Colors.fgMuted
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 2
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            text: detail.value
            color: Colors.fgMuted
            elide: Text.ElideMiddle
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 2
        }
    }

    component AuthButton: Rectangle {
        id: button

        property string label: ""
        property bool primary: false

        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 38
        radius: 11
        opacity: enabled ? 1 : 0.48
        color: primary ? Colors.subtleAccent : Colors.bgTertiary
        border.color: primary ? Colors.mixColor(Colors.bgPrimary, Colors.subtleAccent, 0.2) : Colors.borderLight
        border.width: 0.6
        border.pixelAligned: false
        antialiasing: true

        Text {
            anchors.centerIn: parent
            text: button.label
            color: button.primary ? Colors.fgPrimary : Colors.fgSecondary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        MouseArea {
            anchors.fill: parent
            enabled: button.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
