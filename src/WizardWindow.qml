import QtQuick 2.6
import QtQuick.Window 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Greeter 1.0

Window {
    id: mainWindow
    visible: true
    width: 600
    height: 500
    title: "App Installer Wizard"
    flags: Qt.Dialog | Qt.MSWindowsFixedSizeDialogHint | Qt.WindowCloseButtonHint
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height

    property int stage: 0 // 0: license, 1: next stage
    property bool accepted: false
    property bool cancelDialogOpen: false

    // License Agreement Stage
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12
        visible: mainWindow.stage === 0

        Text {
            Layout.fillWidth: true
            text: "License Agreement"
            font.pixelSize: 28
            font.bold: true
        }
        Text {
            Layout.fillWidth: true
            text: "Please read the following important information before continuing."
            font.pixelSize: 16
            color: "#666"
            wrapMode: Text.WordWrap
        }
        Item { Layout.preferredHeight: 8 }
        Text {
            Layout.fillWidth: true
            text: "Please read the following License Agreement. You must accept the terms of this agreement before continuing with the installation."
            font.pixelSize: 14
            color: "#888"
            wrapMode: Text.WordWrap
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            clip: true
            TextArea {
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim. Pellentesque congue. Ut in risus volutpat libero pharetra tempor. Cras vestibulum bibendum augue. Praesent egestas leo in pede. Praesent blandit odio eu enim. Pellentesque sed dui ut augue blandit sodales. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aliquam nibh. Mauris ac mauris sed pede pellentesque fermentum. Maecenas adipiscing ante non diam sodales hendrerit."
                readOnly: true
                wrapMode: TextArea.Wrap
                width: parent.width
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            RadioButton {
                id: acceptBtn
                text: "I accept the agreement"
                checked: mainWindow.accepted
                onCheckedChanged: mainWindow.accepted = checked
                contentItem: Text {
                    text: acceptBtn.text
                    font: acceptBtn.font
                    color: "#000000"
                    leftPadding: acceptBtn.indicator.width + acceptBtn.spacing
                    verticalAlignment: Text.AlignVCenter
                }
            }
            RadioButton {
                id: rejectBtn
                text: "I do not accept the agreement"
                checked: !mainWindow.accepted
                onCheckedChanged: mainWindow.accepted = !checked
                contentItem: Text {
                    text: rejectBtn.text
                    font: rejectBtn.font
                    color: "#000000"
                    leftPadding: rejectBtn.indicator.width + rejectBtn.spacing
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            spacing: 8
            Item { Layout.fillWidth: true }  // This pushes the buttons to the right
            Button {
                text: "Cancel"
                onClicked: mainWindow.cancelDialogOpen = true
            }
            Button {
                text: "Next"
                enabled: mainWindow.accepted
                onClicked: mainWindow.stage = 1
            }
        }
    }

    // Second Stage Placeholder
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 16
        visible: mainWindow.stage === 1
        Text { text: "Second Stage"; font.pixelSize: 24 }
        Text { text: "(UI elements for the next step go here)"; color: "#888" }
        Item { Layout.fillHeight: true }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Button {
                text: "Back"
                onClicked: mainWindow.stage = 0
            }
            Button {
                text: "Next"
                // Placeholder for next action
            }
        }
    }

    // Cancel Confirmation Dialog
    Dialog {
        id: cancelDialog
        modal: true
        visible: mainWindow.cancelDialogOpen
        title: "Are you sure you want to quit?"
        standardButtons: Dialog.Yes | Dialog.No
        contentItem: Row {
            spacing: 12
            Text { text: "\u26A0\uFE0F"; font.pixelSize: 32 } // ⚠️
            Text { text: "Are you sure you want to quit the installer?"; font.pixelSize: 16 }
        }
        onAccepted: {
            Qt.quit()
        }
        onRejected: mainWindow.cancelDialogOpen = false
    }
}
