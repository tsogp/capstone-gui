

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import Test
import QtQuick.Layouts

Rectangle {
    id: recWindow
    width: 1280
    height: 720

    color: Constants.backgroundColor

    Row {
        id: rowMainframe
        anchors.fill: parent
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
                    spacing: 0

                    Button {
                        id: btAutoplay
                        text: qsTr("Auto")
                        font.pixelSize: 22
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                        font.family: "Tahoma"
                        display: AbstractButton.TextOnly
                        Layout.alignment: Qt.AlignVCenter
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
                        icon.source: "images/fs.png"
                        display: AbstractButton.IconOnly
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Image {
                    id: b89ce100904d45719ba242c2cc56ddc0
                    width: parent.width
                    source: "images/b89ce100-904d-4571-9ba2-42c2cc56ddc0.jpg"
                    sourceSize.width: parent.width
                    fillMode: Image.PreserveAspectFit
                    Layout.alignment: Qt.de
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
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                alignment: Qt.AlignTop

                TextArea {
                    id: txtaInfo
                    color: "#000000"
                    text: "Currently placing {box.name}\n\nPlacement data:\n- x = {box.x}\n- y = {box.y}\n- z = {box.z}\n- Weight = {box.weight}\n- Max load capacity: {box.max_load_capacity}\n- Estimated load: {box.estiomated_load}"
                    placeholderText: qsTr("")
                    font.pixelSize: 20
                    placeholderTextColor: "#000000"
                    font.bold: false
                    font.family: "Tahoma"
                }

                Text {
                    id: txtChoose
                    text: qsTr("Choose the pallet")
                    font.pixelSize: 30
                    font.bold: false
                    font.family: "Tahoma"
                    Layout.bottomMargin: 10
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

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: rowPackageList
                    width: 100
                    height: 100
                    anchors.verticalCenter: true
                    Layout.bottomMargin: 10
                    spacing: 0
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Text {
                        id: txtPackage
                        text: qsTr("Load the package list")
                        font.pixelSize: 30
                        font.family: "Tahoma"
                    }

                    Item {
                        id: item2
                        width: 25
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

                TextField {
                    id: tfFileName
                    placeholderText: qsTr("Filename")
                    Layout.fillWidth: true
                }

                Button {
                    id: btBrowseFiles
                    width: 150
                    height: 60
                    text: qsTr("Browse")
                    font.pixelSize: 24
                    icon.source: "images/free-folder-icon-1485-thumb.png"
                    font.family: "Tahoma"
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: rowButtons
                    fillWidth: true
                    height: btStartSimulation.height
                    spacing: 0

                    Item {
                        id: itControlPanel
                        height: 70
                        Layout.fillWidth: true

                        RowLayout {
                            id: rowLayout2
                            width: 100
                            height: parent.height

                            Button {
                                id: btBacktrack
                                text: qsTr("<")
                                width: 60
                                height: 60
                            }

                            Button {
                                id: btRestart
                                icon.source: "images/relooad.png"
                                display: AbstractButton.IconOnly
                                width: 60
                                height: 60
                                visible: false
                            }

                            Button {
                                id: btPause
                                text: qsTr("|  |")
                                width: 60
                                height: 60
                            }

                            Button {
                                id: btForward
                                text: qsTr(">")
                                width: 60
                                height: 60
                            }
                        }
                    }

                    Button {
                        id: btStartSimulation
                        width: 200
                        height: 70
                        text: qsTr("Cancel simulation")
                        font.pixelSize: 26
                        font.family: "Tahoma"
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0}D{i:13;invisible:true}D{i:14;invisible:true}D{i:19;invisible:true}D{i:20;invisible:true}
D{i:24;invisible:true}D{i:25;invisible:true}
}
##^##*/

