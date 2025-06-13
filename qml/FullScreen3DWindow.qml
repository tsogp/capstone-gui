import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: window.receivedText 

    property string receivedText: ""
    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"

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

    Item {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20

        Text {
            id: previewText
            text: window.receivedText ? window.receivedText : qsTr("Preview Session #321")
            font.pixelSize: 17
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    ColumnLayout {
        id: rangeSliderLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.topMargin: 20
        spacing: 5

        Text {
            text: qsTr("View Slicer")
            font.pixelSize: 17
            horizontalAlignment: Text.AlignLeft
            Layout.alignment: Qt.AlignLeft
        }

        RangeSlider {
            id: rangeSlider
            height: 40
            wheelEnabled: false
            first.value: 0
            second.value: 100
            from: 0
            to: 100
            stepSize: 1
            Layout.fillWidth: true
        }


        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignLeft

            Text {
                text: qsTr("Front: %1%").arg(rangeSlider.first.value)
                font.pixelSize: 14
            }

            Text {
                text: qsTr("Back: %1%").arg(rangeSlider.second.value)
                font.pixelSize: 14
            }
        }
    }

    ColumnLayout {
        id: zoomSliderLayout
        anchors.top: rangeSliderLayout.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.topMargin: 20
        spacing: 5

        Text {
            text: qsTr("Zoom")
            font.pixelSize: 17
            horizontalAlignment: Text.AlignLeft
            Layout.alignment: Qt.AlignLeft
        }

        Slider {
            id: zoomSlider
            height: 40
            wheelEnabled: false
            from: 0.5
            to: 3
            stepSize: 0.1
            value: 1
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignLeft

            Text {
                text: qsTr("Min: %1").arg(zoomSlider.from)
                font.pixelSize: 14
            }

            Text {
                text: qsTr("Max: %1").arg(zoomSlider.to)
                font.pixelSize: 14
            }
        }

        Text {
            text: qsTr("Current: %1").arg(zoomSlider.value.toFixed(2))
            font.pixelSize: 14
        }
    }

    Switch {
        id: autoModeToggle
        anchors.top: zoomSliderLayout.bottom
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.topMargin: 20
        checked: false
        font.pointSize: 14
        text: checked ? qsTr("Auto Mode On") : qsTr("Auto Mode Off")
        onCheckedChanged: {}
    }

    Item {
        width: buttonLayout.implicitWidth
        height: buttonLayout.implicitHeight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            id: buttonLayout
            spacing: 10
            enabled: !autoModeToggle.checked

            Button {
                id: prevStepButton
                height: 40
                width: 40
                icon.source: "qrc:/FullScreen3DView/assets/angle-double-left-24.png"
                display: AbstractButton.IconOnly

                ToolTip.visible: !buttonLayout.enabled && hovered
                ToolTip.text: qsTr("Turn off Auto Mode to enable")
            }

            Button {
                id: pauseButton
                height: 40
                width: 40
                icon.source: "qrc:/FullScreen3DView/assets/pause-24.png"
                display: AbstractButton.IconOnly

                ToolTip.visible: !buttonLayout.enabled && hovered
                ToolTip.text: qsTr("Turn off Auto Mode to enable")
            }

            Button {
                id: nextStepButton
                height: 40
                width: 40
                icon.source: "qrc:/FullScreen3DView/assets/angle-double-right-24.png"
                display: AbstractButton.IconOnly

                ToolTip.visible: !buttonLayout.enabled && hovered
                ToolTip.text: qsTr("Turn off Auto Mode to enable")
            }
        }
    }

    DebugView {
        anchors.top: parent.top
        anchors.right: parent.right
        source: view
    }
}
