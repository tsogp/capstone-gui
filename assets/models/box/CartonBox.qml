import QtQuick
import QtQuick3D

Node {
    id: cartonBox
    property vector3d dimensions: Qt.vector3d(0, 0, 0)
    property int animationDuration: 1000
    property alias model: cartonBoxModel
    property int boxId: 0

    // Random RGB once per box
    property real randR: Math.random()
    property real randG: Math.random()
    property real randB: Math.random()

    // Fade-in opacity property
    property real opacityValue: 0.0

    // Current color state
    property color currentColor: Qt.rgba(randR, randG, randB, opacityValue)

    Model {
        id: cartonBoxModel
        objectName: "cartonBoxModel"
        source: "#Cube"
        pickable: true
        property bool isPicked: false

        materials: DefaultMaterial {
            id: mat
            diffuseColor: currentColor
            opacity: opacityValue
        }

        // Animate color change when picked/unpicked
        onIsPickedChanged: {
            colorAnim.from = currentColor
            colorAnim.to = isPicked
                ? Qt.rgba(1, 1, 0, opacityValue) // highlight yellow
                : Qt.rgba(randR, randG, randB, opacityValue) // original
            colorAnim.start()
        }
    }

    // Fade-in animation
    NumberAnimation on opacityValue {
        from: 0.0
        to: 1.0
        duration: animationDuration
        running: true
    }

    // Color animation
    ColorAnimation {
        id: colorAnim
        target: cartonBox
        property: "currentColor"
        duration: 50
    }
}
