import QtQuick
import QtQuick3D

Node {
    id: cartonBox
    property vector3d dimensions: Qt.vector3d(0, 0, 0)
    property int animationDuration: 1000
    property alias model: cartonBoxModel
    property int boxId: 0

    // Fade-in opacity property
    property real opacityValue

    Model {
        id: cartonBoxModel
        objectName: "cartonBoxModel"
        source: "#Cube"
        pickable: true
        property bool isPicked: false

        materials: DefaultMaterial {
            id: mat
            diffuseColor: Qt.rgba(0.2, 0.6, 1.0, cartonBox.opacityValue) // blue with fade
            opacity: cartonBox.opacityValue
        }
    }

    // Fade-in animation (runs on cartonBox.opacityValue)
    NumberAnimation on opacityValue {
        from: 0.0
        to: 1.0
        duration: cartonBox.animationDuration
        running: true
    }
}
