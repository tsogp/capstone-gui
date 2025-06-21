import QtQuick
import QtQuick3D

Node {
    id: cartonBox

    Model {
        id: cartonBoxModel
        source: "meshes/carton_box.mesh"
        materials: [
            PrincipledMaterial {
                id: cartonBoxDefaultMaterial
                baseColorMap: Texture {
                    source: "qrc:/FullScreen3DView/assets/models/box/textures/carton_box.jpg"
                }
                roughness: 1
                indexOfRefraction: 1
            }
        ]
    }
}
