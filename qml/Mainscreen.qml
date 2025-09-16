import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Window {
    id: mainscreen
    width: 1280
    height: 720
    visible: true
    title: qsTr("Load file")

    property bool isLoading: mainWindow.isRequestInProgress
    property string serverURL: "http://127.0.0.1:8000"

    AddBoxesForSessionDialog {
        id: addBoxesForSessionDialog
    }

    Connections {
        target: mainWindow

        function onPalletInfoUpdated(info) {
            txtPalletInfo.text = info;
        }

        function onSimulationStarted(resultStats) {
            choicesColLayout.visible = false;
            rowButtons.visible = false;

            txtBox.visible = true;
            txtBoxInfo.visible = true;
            txtBoxInfo.text = qsTr("Simulation started. Click on boxes to interact with them.");

            rowResult.visible = true;
            txtResultStats.visible = true;
        }

        function onResultStatsReceived(resultStats) {
            txtResultStats.text = resultStats;
        }

        function onBoxInfoUpdated(info) {
            txtBoxInfo.text = info;
        }

        function onBoxInfoCleared() {
            txtBoxInfo.text = qsTr("Simulation started. Click on boxes to interact with them.");
        }

        function onIsRequestInProgressChanged() {
            console.log("here", mainWindow.isRequestInProgress);
            isLoading = mainWindow.isRequestInProgress;
        }

        function onProgressValueChanged() {
            statusLabel.text = qsTr("Status: ") + mainWindow.progressValue + "%";
            progressBar.value = mainWindow.progressValue;
        }

        function onClearMainScreen() {
            colRightPanel.visible = true;
            choicesColLayout.visible = true;
            rowButtons.visible = true;

            txtBox.visible = false;
            txtBoxInfo.visible = false;
            txtBoxInfo.text = "";

            rowResult.visible = false;
            txtResultStats.visible = false;
        }
    }

    Rectangle {
        id: mainScreen
        anchors.fill: parent
        color: "#f0f0f0"
        visible: true

        RowLayout {
            id: rowMainframe
            anchors.fill: parent
            spacing: 0

            Item {
                id: itLeftPanel
                Layout.preferredWidth: parent.width / 2
                Layout.preferredHeight: parent.height

                ColumnLayout {
                    id: colLeftPanel
                    width: parent.width
                    height: parent.height
                    anchors.centerIn: parent
                    spacing: 0
                    Layout.alignment: Qt.AlignCenter

                    Item {
                        id: halfScreen3DSpace
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        StackLayout {
                            id: layout
                            anchors.fill: parent
                            currentIndex: mainWindow.isFullScreenViewOpen ? 1 : 0

                            Loader {
                                id: halfScreenLoader
                                active: layout.currentIndex === 0
                                sourceComponent: threeDViewComponent
                            }

                            Text {
                                text: qsTr("The 3D view is now in fullscreen.")
                                Layout.alignment: Qt.AlignCenter
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap
                            }

                            Component {
                                id: threeDViewComponent
                                ThreeDView {
                                    id: halfScreenView
                                    fromFullScreen: false
                                }
                            }
                        }

                        Button {
                            id: btFullscreen
                            enabled: !isLoading
                            anchors.top: halfScreen3DSpace.top
                            anchors.topMargin: 20
                            anchors.right: halfScreen3DSpace.right
                            anchors.rightMargin: 20
                            padding: 0
                            Layout.fillWidth: false
                            icon.height: 24
                            icon.width: 24
                            icon.source: "qrc:/FullScreen3DView/assets/fullscreen-24.png"
                            display: AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: mainWindow.openFullScreen3DWindow("Preview session #321")
                        }
                    }
                }
            }

            Rectangle {
                id: recDivider
                Layout.preferredWidth: 3
                Layout.preferredHeight: parent.height
                Layout.fillHeight: true
                color: "#000000"
                border.width: 5
            }

            Item {
                id: itRightPanel
                Layout.preferredWidth: parent.width / 2
                Layout.preferredHeight: parent.height

                ColumnLayout {
                    id: colRightPanel
                    width: parent.width - 80
                    height: parent.height - 80
                    spacing: 10
                    anchors.centerIn: parent
                    Layout.alignment: Qt.AlignTop

                    Text {
                        id: txtBox
                        color: "#000000"
                        text: "Box Information"
                        font.pixelSize: 18
                        font.bold: true
                        visible: false
                    }

                    Text {
                        id: txtBoxInfo
                        color: "#000000"
                        text: "Currently placing {box.name}\n\nPlacement data:\n- x = {box.x}\n- y = {box.y}\n- z = {box.z}\n- Weight = {box.weight}\n- Max load capacity: {box.max_load_capacity}\n- Estimated load: {box.estiomated_load}"
                        font.pixelSize: 16
                        visible: false
                    }

                    RowLayout {
                        id: rowResult
                        visible: false

                        Text {
                            id: txtResult
                            color: "#000000"
                            text: "Result"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: resultTooltip
                            icon.height: 24
                            icon.width: 24
                            icon.source: "qrc:/FullScreen3DView/assets/info-24.png"
                            icon.color: "#006dd9"
                            display: AbstractButton.IconOnly
                            ToolTip.visible: hovered
                            ToolTip.delay: 0
                            ToolTip.text: "Volume utilization is the volume of all boxes divided by total volume of pallet. The higher the ratio the higher the score.\n\nGlobal air exposure ratio is the total amount of gaps between boxes. The lesser the gaps the higher the score.\n\nCenter of gravity (CoG) refers to the CoG of all the boxes relative to the pallet. The closer it is to the bottom and middle, the higher the score.\n\n***Fitness score is a weighted score of all the scores above"
                        }
                    }

                    Text {
                        id: txtResultStats
                        color: "#000000"
                        font.pixelSize: 16
                        visible: false
                    }

                    ColumnLayout {
                        id: choicesColLayout
                        Layout.preferredWidth: parent.width
                        spacing: 10

                        Text {
                            id: txtChoose
                            text: qsTr("Choose the pallet")
                            font.pixelSize: 17
                            font.bold: true
                        }

                        ComboBox {
                            id: cbPallet
                            enabled: !isLoading
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: 30
                            editable: false
                            model: ListModel {
                                ListElement {
                                    text: "Euro"
                                }
                                ListElement {
                                    text: "Industrial"
                                }
                                ListElement {
                                    text: "Asia"
                                }
                            }
                            font.pixelSize: 16
                            Layout.fillWidth: true
                            onActivated: mainWindow.updatePalletInfo(currentText)
                            Component.onCompleted: mainWindow.updatePalletInfo(currentText)
                        }

                        Text {
                            text: qsTr("Pallet Info")
                            font.pixelSize: 17
                            font.bold: true
                        }

                        Text {
                            id: txtPalletInfo
                            font.pixelSize: 16
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            id: boxModeLayout
                            Layout.fillWidth: true
                            spacing: 12

                            RowLayout {
                                spacing: 10
                                Label {
                                    text: qsTr("Mode:")
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                                Switch {
                                    id: modeSwitch
                                    text: checked ? "Load from file" : "Add manually"
                                    checked: false
                                }
                            }

                            StackLayout {
                                Layout.fillWidth: true
                                currentIndex: modeSwitch.checked ? 1 : 0

                                ColumnLayout {
                                    spacing: 8

                                    Button {
                                        id: openAddBoxesSession
                                        enabled: !isLoading
                                        Layout.fillWidth: true
                                        text: qsTr("Add boxes to session")
                                        font.pixelSize: 16
                                        onClicked: addBoxesForSessionDialog.open()
                                    }
                                }

                                ColumnLayout {
                                    spacing: 8

                                    RowLayout {
                                        id: rowPackageList
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            id: txtPackage
                                            text: qsTr("Load the package list")
                                            font.pixelSize: 17
                                            font.bold: true
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 10
                                        }

                                        Button {
                                            id: roundButton
                                            enabled: !isLoading
                                            icon.height: 24
                                            icon.width: 24
                                            icon.source: "qrc:/FullScreen3DView/assets/info-24.png"
                                            icon.color: "#006dd9"
                                            display: AbstractButton.IconOnly
                                            ToolTip.visible: hovered
                                            ToolTip.delay: 0
                                            ToolTip.text: "Expected format:\n{\n  \"boxes\": [\n    { \"w\": int, \"l\": int, \"h\": int,\n      \"weight\": float, \"max_load\": int }\n  ]\n}"
                                        }
                                    }

                                    Button {
                                        id: btBrowseFiles
                                        enabled: !isLoading
                                        Layout.fillWidth: true
                                        text: qsTr("Browse")
                                        font.pixelSize: 16
                                        icon.source: "qrc:/FullScreen3DView/assets/folder-24.png"
                                        onClicked: inputBoxFileDialog.open()
                                    }

                                    FileDialog {
                                        id: inputBoxFileDialog
                                        title: "Select a JSON file"
                                        nameFilters: ["JSON files (*.json)"]
                                        fileMode: FileDialog.OpenFile
                                        onAccepted: {
                                            mainWindow.processBoxesJsonFile(inputBoxFileDialog.selectedFile);
                                        }
                                    }

                                    Button {
                                        text: "Preview JSON"
                                        enabled: mainWindow.isJsonLoaded && !isLoading
                                        onClicked: {
                                            const component = Qt.createComponent("qrc:/FullScreen3DView/qml/PreviewWindow.qml");
                                            if (component.status === Component.Ready) {
                                                const preview = component.createObject(null);
                                                if (!preview)
                                                    console.log("Failed to create PreviewWindow");
                                            } else {
                                                console.log("Failed to load PreviewWindow.qml:", component.errorString());
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                id: jsonErrorText
                                width: Layout.fillWidth
                                text: mainWindow.jsonErrorMessage
                                color: "red"
                                font.bold: true
                                visible: text.length > 0
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        id: rowButtons
                        Layout.fillWidth: true
                        Layout.preferredHeight: btStartSimulation.height

                        Item {
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            visible: isLoading

                            Text {
                                id: statusLabel
                                text: "Status: Loading..."
                            }

                            ProgressBar {
                                id: progressBar
                                from: 0
                                to: 100
                                value: 0
                            }
                        }

                        Button {
                            id: btStartSimulation
                            enabled: mainWindow.isJsonLoaded && !isLoading
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 40
                            text: qsTr("Start simulation")
                            font.pixelSize: 16
                            onClicked: {
                                mainWindow.startSimulation();
                            }
                        }
                    }
                }
            }
        }

        Button {
            id: restartButton
            visible: mainWindow.hasSimulationStarted && !isLoading
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 20
            anchors.rightMargin: 20
            font.pixelSize: 16
            text: qsTr("Complete simulation and restart")
            onClicked: mainWindow.restartSimulation()
        }
    }
}
