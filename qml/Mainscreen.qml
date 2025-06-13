import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts

// Preview: "C:\Qt\6.9.0\mingw_64\bin\qmlscene.exe" then select the Main.qml file

Window {
    id: root
    visible: true
    width: 1920
    height: 1080
    title: qsTr("Qt Design Studio Loader Example")

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
                    width: parent.width - 80
                    height: parent.height - 80
                    anchors.centerIn: parent
                    spacing: 0
                    Layout.alignment: Qt.AlignCenter

                    RowLayout {
                        id: rowControlPanel
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height
                        spacing: 0

                        Switch {
                            id: btToggleAuto
                            text: qsTr("Toggle Auto Mode")
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: btFullscreen
                            Layout.preferredHeight: 57
                            text: qsTr("Fullscreen")
                            font.pixelSize: 22
                            padding: 0
                            Layout.fillWidth: false
                            icon.height: 22
                            icon.width: 22
                            icon.source: "qrc:/FullScreen3DView/assets/fullscreen-512.png"
                            display: AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            // TODO: replace with actual value
                            onClicked: mainWindow.openFullScreen3DWindow("Preview session #321")
                        }
                    }

                    Image {
                        id: visual1056697
                        Layout.preferredWidth: parent.width
                        source: "images/visual-1056-697.jpg"
                        sourceSize.width: parent.width
                        fillMode: Image.PreserveAspectCrop
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

                    TextArea {
                        id: txtaInfo
                        color: "#000000"
                        text: "Currently placing {box.name}\n\nPlacement data:\n- x = {box.x}\n- y = {box.y}\n- z = {box.z}\n- Weight = {box.weight}\n- Max load capacity: {box.max_load_capacity}\n- Estimated load: {box.estiomated_load}"
                        font.pixelSize: 20
                        font.family: "Tahoma"
                        visible: false
                    }

                    ColumnLayout {
                        id: choicesColLayout
                        Layout.preferredWidth: parent.width
                        spacing: 10

                        Text {
                            id: txtChoose
                            text: qsTr("Choose the pallet")
                            font.pixelSize: 30
                            font.family: "Tahoma"
                        }

                        ComboBox {
                            id: cbPallet
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: 60
                            editable: false
                            model: ListModel {
                                ListElement { text: "EUR" }
                                ListElement { text: "Industrial" }
                                ListElement { text: "Asia" }
                            }
                            font.pixelSize: 24
                            font.family: "Tahoma"
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            id: rowPackageList
                            Layout.preferredHeight: 100
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                id: txtPackage
                                text: qsTr("Load the package list")
                                font.pixelSize: 30
                                font.family: "Tahoma"
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            RoundButton {
                                id: roundButton
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 50
                                icon.height: 30
                                icon.width: 30
                                icon.source: "qrc:/FullScreen3DView/assets/info-512.png"
                                icon.color: "#006dd9"
                                display: AbstractButton.IconOnly
                            }
                        }

                        Button {
                            id: btBrowseFiles
                            objectName: "btBrowseFiles"
                            Layout.fillWidth: true
                            text: qsTr("Browse")
                            font.pixelSize: 24
                            icon.source: "qrc:/FullScreen3DView/assets/folder-512.png"
                            font.family: "Tahoma"
                            onClicked: {
                                root.state = "FileLoaded"
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
                        spacing: 0
                        visible: false

                        Item {
                            id: itControlPanel
                            Layout.preferredHeight: 70
                            Layout.fillWidth: true

                            RowLayout {
                                id: rowLayout2
                                Layout.fillWidth: true
                                spacing: 5
                                height: parent.height

                                Button {
                                    id: prevStepButton
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    icon.source: "qrc:/FullScreen3DView/assets/angle-double-left-24.png"
                                    display: AbstractButton.IconOnly
                                    visible: false
                                }

                                Button {
                                    id: restartButton
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    icon.source: "qrc:/FullScreen3DView/assets/reload.png"
                                    display: AbstractButton.IconOnly
                                    visible: false
                                }

                                Button {
                                    id: pauseButton
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    icon.source: "qrc:/FullScreen3DView/assets/pause-24.png"
                                    display: AbstractButton.IconOnly
                                    visible: false
                                }

                                Button {
                                    id: nextStepButton
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    icon.source: "qrc:/FullScreen3DView/assets/angle-double-right-24.png"
                                    display: AbstractButton.IconOnly
                                    visible: false
                                }
                            }
                        }

                        Button {
                            id: btStartSimulation
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 40
                            text: qsTr("Start simulation")
                            font.pixelSize: 26
                            font.family: "Tahoma"
                        }
                    }
                }
            }
        }

        StateGroup {
            id: stateGroup
        }

        states: [
            State {
                name: "FileLoaded"
                PropertyChanges { target: rowButtons.visible = true}
            },
            State {
                name: "Simulation"
                PropertyChanges { target: choicesColLayout.visible = false }
                PropertyChanges { target: txtaInfo.visible = true }
                PropertyChanges { target: rowButtons.visible = true }
                PropertyChanges { target: prevStepButton.visible = true }
                PropertyChanges { target: pauseButton.visible = true }
                PropertyChanges { target: nextStepButton.visible = true }
            },
            State {
                name: "EndSimulation"
                PropertyChanges { target: choicesColLayout.visible = false }
                PropertyChanges { target: txtaInfo.visible = true }
                PropertyChanges { target: rowButtons.visible = true }
                PropertyChanges { target: prevStepButton.visible = true }
                PropertyChanges { target: restartButton.visible = true }
                PropertyChanges { target: pauseButton.visible = false }
                PropertyChanges { target: nextStepButton.visible = false }
                PropertyChanges { target: btStartSimulation.text = qsTr("Finish simulation") }
            }
        ]
    }
}
