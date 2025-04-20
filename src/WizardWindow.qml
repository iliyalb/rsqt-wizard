import Greeter 1.0
import QtQuick 2.6
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.0

Window {
    id: mainWindow

    property int stage: 0 // 0: license, 1: directory selection, 2: ready to install, 3: installing, 4: complete
    property bool accepted: false
    property bool cancelDialogOpen: false

    visible: true
    width: 600
    height: 500
    title: "Installer Wizard"
    flags: Qt.Dialog | Qt.MSWindowsFixedSizeDialogHint | Qt.WindowCloseButtonHint
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height

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

        Item {
            Layout.preferredHeight: 8
        }

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

            // This pushes the buttons to the right
            Item {
                Layout.fillWidth: true
            }

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

    // Second Stage - Directory Selection
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12
        visible: mainWindow.stage === 1

        Text {
            Layout.fillWidth: true
            text: "Select Destination Location"
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            text: "Setup will install files into the following directory."
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: "To continue, click Next. If you would like to select a different directory, click Browse."
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.preferredHeight: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: pathField

                Layout.fillWidth: true
                text: greeter.install_path
                onTextChanged: greeter.set_install_path(text)
            }

            Button {
                text: "Browse..."
                onClicked: greeter.browse_directory()
            }

        }

        Item {
            Layout.preferredHeight: 24
        }

        CheckBox {
            text: "Create a desktop shortcut"
            checked: greeter.create_shortcut
            onCheckedChanged: greeter.set_create_shortcut(checked)

            contentItem: Row {
                spacing: 10

                Rectangle {
                    width: 20
                    height: 20
                    border.width: 1

                    Rectangle {
                        width: 10
                        height: 10
                        x: 5
                        y: 5
                        color: "blue"
                        visible: parent.parent.checked
                    }

                }

                Text {
                    text: parent.parent.text
                    color: "#777"
                }

            }

        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.fillWidth: true
            text: "At least " + greeter.calculate_required_space() + " MB of free disk space is required."
            font.pixelSize: 14
            color: "#666666"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            spacing: 8

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: "Cancel"
                onClicked: mainWindow.cancelDialogOpen = true
            }

            Button {
                text: "Back"
                onClicked: mainWindow.stage = 0
            }

            Button {
                text: "Next"
                onClicked: mainWindow.stage = 2
            }

        }

    }

    // Third Stage - Ready to Install
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12
        visible: mainWindow.stage === 2

        Text {
            Layout.fillWidth: true
            text: "Ready to Install"
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            text: "Setup will install files to:"
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: greeter.install_path
            font.pixelSize: 14
            font.family: "monospace"
            color: "#000000"
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: "Click Install to begin the installation."
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            spacing: 8
            Item { Layout.fillWidth: true }
            Button {
                text: "Cancel"
                onClicked: mainWindow.cancelDialogOpen = true
            }
            Button {
                text: "Back"
                onClicked: mainWindow.stage = 1
            }
            Button {
                text: "Install"
                onClicked: {
                    mainWindow.stage = 3
                    greeter.start_installation()
                }
            }
        }
    }

    // Fourth Stage - Installing
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12
        visible: mainWindow.stage === 3 && !greeter.installation_complete

        Text {
            Layout.fillWidth: true
            text: "Installing"
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            text: "Please wait while setup installs files on your computer."
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: "Extracting files..."
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: greeter.current_file
            font.pixelSize: 12
            font.family: "monospace"
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        ProgressBar {
            Layout.fillWidth: true
            value: greeter.progress / 100
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            spacing: 8
            Item { Layout.fillWidth: true }
            Button {
                text: "Cancel"
                onClicked: mainWindow.cancelDialogOpen = true
            }
        }
    }

    // Fifth Stage - Complete
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12
        visible: mainWindow.stage === 3 && greeter.installation_complete

        Text {
            Layout.fillWidth: true
            text: "Installation Complete"
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            text: "Wizard has finished installing files on your computer."
            font.pixelSize: 14
            color: "#666666"
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            spacing: 8
            Item { Layout.fillWidth: true }
            Button {
                text: "Finish"
                onClicked: Qt.quit()
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
        onAccepted: {
            Qt.quit();
        }
        onRejected: mainWindow.cancelDialogOpen = false

        contentItem: Row {
            spacing: 12

            // ⚠️
            Text {
                text: "\u26A0\uFE0F"
                font.pixelSize: 32
            }

            Text {
                text: "Are you sure you want to quit the installer?"
                font.pixelSize: 16
                color: "#FF0400FF"
            }

        }

    }

    Greeter {
        id: greeter
    }

}
