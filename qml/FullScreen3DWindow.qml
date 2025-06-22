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

    Connections {
        target: settingsBridge

        function onZoomLevelChanged() {
            zoomSlider.value = settingsBridge.zoomLevel;
        }

        function onViewSliderFirstChanged() {
            viewSlider.first.value = settingsBridge.viewSliderFirst;
        }

        function onViewSliderSecondChanged() {
            viewSlider.second.value = settingsBridge.viewSliderSecond;
        }

        function onIsAutoModeChanged() {
            autoModeToggle.checked = settingsBridge.isAutoMode;
        }
    }

    Component.onCompleted: {
        zoomSlider.value = settingsBridge.zoomLevel
        viewSlider.first.value = settingsBridge.viewSliderFirst
        viewSlider.second.value = settingsBridge.viewSliderSecond
        autoModeToggle.checked = settingsBridge.isAutoMode
    }

    ThreeDView {
        id: threeDView
        anchors.fill: parent
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
            Layout.alignment: Qt.AlignLeft
        }

        RangeSlider {
            id: viewSlider
            objectName: "viewSlider"
            height: 40
            wheelEnabled: false
            first.value: settingsBridge.viewSliderFirst
            second.value: settingsBridge.viewSliderSecond
            from: 0
            to: 100
            stepSize: 1
            Layout.fillWidth: true

            first.onValueChanged: settingsBridge.viewSliderFirst = first.value
            second.onValueChanged: settingsBridge.viewSliderSecond = second.value
        }


        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignLeft

            Text {
                text: qsTr("Front: %1%").arg(viewSlider.first.value)
                font.pixelSize: 14
            }

            Text {
                text: qsTr("Back: %1%").arg(viewSlider.second.value)
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
            Layout.alignment: Qt.AlignLeft
        }

        Slider {
            id: zoomSlider
            objectName: "zoomSlider"
            height: 40
            wheelEnabled: false
            from: 0.5
            to: 3
            stepSize: 0.1
            value: settingsBridge.zoomLevel
            Layout.fillWidth: true

            onValueChanged: settingsBridge.zoomLevel = value
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
        objectName: "autoModeToggle"
        anchors.top: zoomSliderLayout.bottom
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.topMargin: 20
        checked: settingsBridge.isAutoMode
        font.pointSize: 14
        text: checked ? qsTr("Auto Mode On") : qsTr("Auto Mode Off")

        onCheckedChanged: settingsBridge.isAutoMode = checked
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
        source: threeDView.view
    }
}
