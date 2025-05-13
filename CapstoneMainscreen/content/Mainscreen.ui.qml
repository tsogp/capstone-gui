

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.5
import QtQuick.Controls 6.5
import CapstoneMainscreen
import QtQuick.Layouts

Rectangle {
    id: mainScreen
    width: Constants.width
    height: Constants.height
    color: Constants.backgroundColor
    visible: true

    RowLayout {
        id: rowMainframe
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        spacing: 0

        Item {
            id: itLeftPanel
            width: parent.width / 2
            height: parent.height

            ColumnLayout {
                id: colLeftPanel
                width: parent.width - 80
                height: parent.height - 80
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0
                Layout.alignment: Qt.AlignCenter

                RowLayout {
                    id: rowControlPanel
                    width: parent.width
                    height: parent.height
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
                        height: 57
                        text: qsTr("Fullscreen")
                        font.pixelSize: 22
                        padding: 0
                        Layout.fillWidth: false
                        icon.height: 22
                        icon.width: 22
                        icon.source: "images/fullscreen.png"
                        display: AbstractButton.IconOnly
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Image {
                    id: visual1056697
                    width: parent.width
                    source: "images/visual-1056-697.jpg"
                    sourceSize.width: parent.width
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        Rectangle {
            id: recDivider
            width: 3
            height: parent.height
            Layout.fillHeight: true
            color: "#000000"
            border.width: 5
        }

        Item {
            id: itRightPanel
            width: parent.width / 2
            height: parent.height

            ColumnLayout {
                id: colRightPanel
                width: parent.width - 80
                height: parent.height - 80
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignTop

                TextArea {
                    id: txtaInfo
                    color: "#000000"
                    text: "Currently placing {box.name}\n\nPlacement data:\n- x = {box.x}\n- y = {box.y}\n- z = {box.z}\n- Weight = {box.weight}\n- Max load capacity: {box.max_load_capacity}\n- Estimated load: {box.estiomated_load}"
                    placeholderText: qsTr("")
                    font.pixelSize: 20
                    placeholderTextColor: "#000000"
                    font.bold: false
                    font.family: "Tahoma"
                    visible: false
                }

                ColumnLayout {
                    id: choicesColLayout
                    width: parent.width
                    spacing: 10

                    Text {
                        id: txtChoose
                        text: qsTr("Choose the pallet")
                        font.pixelSize: 30
                        font.bold: false
                        font.family: "Tahoma"
                    }

                    ComboBox {
                        id: cbPallet
                        width: parent.width
                        height: 60
                        editable: false
                        model: ListModel {
                            id: model
                            ListElement {
                                text: "EUR"
                            }
                            ListElement {
                                text: "Industrial"
                            }
                            ListElement {
                                text: "Asia"
                            }
                        }
                        font.pixelSize: 24
                        font.family: "Tahoma"
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        id: rowPackageList
                        height: 100
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            id: txtPackage
                            text: qsTr("Load the package list")
                            font.pixelSize: 30
                            font.bold: false
                            font.family: "Tahoma"
                        }

                        Item {
                            id: item2
                            Layout.fillWidth: true
                            height: 10
                        }

                        RoundButton {
                            id: roundButton
                            width: 50
                            height: 50
                            opacity: 1
                            text: ""
                            font.pixelSize: 30
                            flat: false
                            icon.height: 30
                            icon.width: 30
                            icon.source: "images/info.png"
                            icon.color: "#006dd9"
                            font.family: "Times New Roman"
                            display: AbstractButton.IconOnly
                        }
                    }

                    Button {
                        id: btBrowseFiles
                        objectName: "btBrowseFiles"
                        Layout.fillWidth: true
                        width: parent.width
                        text: qsTr("Browse")
                        font.pixelSize: 24
                        icon.source: "images/folder.png"
                        font.family: "Tahoma"
                    }


                }


                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: rowButtons
                    Layout.fillWidth: true
                    height: btStartSimulation.height
                    spacing: 0
                    visible: false

                    Item {
                        id: itControlPanel
                        height: 70
                        Layout.fillWidth: true
                        visible: true

                        RowLayout {
                            id: rowLayout2
                            Layout.fillWidth: true
                            spacing: 5
                            height: parent.height

                            Button {
                                id: prevStepButton
                                width: 40
                                height: 40
                                icon.source: "images/angle-double-left-24.png"
                                display: AbstractButton.IconOnly
                                visible: false
                            }

                            Button {
                                id: restartButton
                                width: 40
                                height: 40
                                icon.source: "images/reload.png"
                                display: AbstractButton.IconOnly
                                visible: false
                            }

                            Button {
                                id: pauseButton
                                width: 40
                                height: 40
                                icon.source: "images/pause-24.png"
                                display: AbstractButton.IconOnly
                                visible: false
                            }

                            Button {
                                id: nextStepButton
                                width: 40
                                height: 40
                                icon.source: "images/angle-double-right-24.png"
                                display: AbstractButton.IconOnly
                                visible: false
                            }
                        }
                    }

                    Button {
                        id: btStartSimulation
                        width: 200
                        height: 40
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
            PropertyChanges {
                target:rowButtons
                visible: true
            }
        },
        State {
            name: "Simulation"
            PropertyChanges {
                target: choicesColLayout
                visible: false
            }
            PropertyChanges {
                target: txtaInfo
                visible: true
            }
            PropertyChanges {
                target:rowButtons
                visible: true
            }
            PropertyChanges {
                target: prevStepButton
                visible: true
            }
            PropertyChanges {
                target: pauseButton
                visible: true
            }
            PropertyChanges {
                target: nextStepButton
                visible: true
            }
        },
        State {
            name: "EndSimulation"
            PropertyChanges {
                target: choicesColLayout
                visible: false
            }
            PropertyChanges {
                target: txtaInfo
                visible: true
            }
            PropertyChanges {
                target:rowButtons
                visible: true
            }
            PropertyChanges {
                target: prevStepButton
                visible: true
            }
            PropertyChanges {
                target: restartButton
                visible: true
            }
            PropertyChanges {
                target: pauseButton
                visible: false
            }
            PropertyChanges {
                target: nextStepButton
                visible: false
            }
            PropertyChanges {
                target: btStartSimulation
                text: qsTr("Finish simulation")
            }
        }

    ]
}
