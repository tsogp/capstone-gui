import QtQuick
import QtQuick3D

Node {
    id: cartonBox

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
    }
}
