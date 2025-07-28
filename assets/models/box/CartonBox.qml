import QtQuick
import QtQuick3D

Node {
    id: cartonBox
    property vector3d dimensions: Qt.vector3d(0, 0, 0)
    property int animationDuration: 1000
    property real animStartY
    property real animEndY

    property alias model: cartonBoxModel

    property int boxId: 0
    
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
            }
        ]

        SequentialAnimation on y {
            NumberAnimation {
                duration: animationDuration
                to: cartonBox.animEndY
                from: cartonBox.animStartY
                easing.type: Easing.InQuad
            }
        }
    }
}
