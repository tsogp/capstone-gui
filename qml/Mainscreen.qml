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

    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"

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

                    RowLayout {
                        id: rowControlPanel
                        Layout.preferredWidth: parent.width
                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: btFullscreen
                            text: qsTr("Fullscreen")
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

                    Item {
                        id: halfScreen3DSpace
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        View3D {
                            id: view
                            anchors.fill: parent

                            environment: SceneEnvironment {
                                id: sceneEnvironment
                                clearColor: "white"
                                backgroundMode: SceneEnvironment.Color
                                antialiasingMode: SceneEnvironment.MSAA
                                antialiasingQuality: SceneEnvironment.High
                            }

                            PerspectiveCamera {
                                id: camera
                                position: Qt.vector3d(0, 10, 300)
                                clipNear: 1.0
                            }

                            DirectionalLight {
                                position: Qt.vector3d(0, 430, 900)
                                brightness: 1
                                eulerRotation.z: -19.212
                                eulerRotation.x: -25.34759
                                eulerRotation.y: -2.67751
                                ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
                            }

                            Loader3D {
                                id: palletLoader
                                source: currentModelSource
                                active: true

                                onLoaded: {
                                    item.position = Qt.vector3d(0, 30, 0)
                                    item.eulerRotation = Qt.vector3d(15, 70, 30)
                                    item.scale = Qt.vector3d(1.5, 1.5, 1.5)
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
                            font.pixelSize: 16
                            
                        }

                        ComboBox {
                            id: cbPallet
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: 30
                            editable: false
                            model: ListModel {
                                ListElement { text: "EUR" }
                                ListElement { text: "Industrial" }
                                ListElement { text: "Asia" }
                            }
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            id: rowPackageList
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                id: txtPackage
                                text: qsTr("Load the package list")
                                font.pixelSize: 16
                                
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
