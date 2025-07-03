import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Window {
    id: mainscreen
    width: 1280
    height: 720
    visible: true
    title: qsTr("Load file")

    Connections {
        target: mainWindow

        function onPalletInfoUpdated(info) {
            txtPalletInfo.text = info;
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
                                }
                            }
                        }

                        Button {
                            id: btFullscreen
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
                            // TODO: replace with actual value
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

                    TextArea {
                        id: txtaInfo
                        color: "#000000"
                        text: "Currently placing {box.name}\n\nPlacement data:\n- x = {box.x}\n- y = {box.y}\n- z = {box.z}\n- Weight = {box.weight}\n- Max load capacity: {box.max_load_capacity}\n- Estimated load: {box.estiomated_load}"
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
                            onActivated: {
                                mainWindow.updatePalletInfo(currentText);
                            }

                            Component.onCompleted: {
                                mainWindow.updatePalletInfo(currentText);
                            }
                        }

                        Text {
                            text: qsTr("Pallet Info:")
                            font.pixelSize: 17
                            font.bold: true
                        }

                        Text {
                            id: txtPalletInfo
                            font.pixelSize: 16
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

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
                                icon.height: 24
                                icon.width: 24
                                icon.source: "qrc:/FullScreen3DView/assets/info-24.png"
                                icon.color: "#006dd9"
                                display: AbstractButton.IconOnly
                            }
                        }

                        Button {
                            id: btBrowseFiles
                            objectName: "btBrowseFiles"
                            Layout.fillWidth: true
                            text: qsTr("Browse")
                            font.pixelSize: 16
                            icon.source: "qrc:/FullScreen3DView/assets/folder-24.png"
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
                            Layout.fillWidth: true
                        }

                        Button {
                            id: btStartSimulation
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 40
                            text: qsTr("Start simulation")
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }
}
