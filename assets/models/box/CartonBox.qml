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
        source: "meshes/carton_box.mesh"
        pickable: true
        property bool isPicked: false

        materials: [
            PrincipledMaterial {
                id: cartonBoxDefaultMaterial
                baseColorMap: Texture {
                    source: cartonBoxModel.isPicked ?
                                "" : "qrc:/FullScreen3DView/assets/models/box/textures/carton_box.jpg"
                }
                roughness: 1
                indexOfRefraction: 1

                // Fade-in transparency
                opacity: cartonBox.opacityValue
                baseColor: Qt.rgba(1, 1, 1, cartonBox.opacityValue)
            }
        ]
    }

    // Fade-in animation (runs on cartonBox.opacityValue)
    NumberAnimation on opacityValue {
        from: 0.0
        to: 1.0
        duration: cartonBox.animationDuration
        running: true
    }
}
