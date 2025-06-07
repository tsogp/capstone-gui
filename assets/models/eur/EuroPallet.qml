import QtQuick
import QtQuick3D

Node {
    id: euroPallet

    scale: Qt.vector3d(2, 2, 2)

    Model {
        source: "qrc:/FullScreen3DView/assets/models/eur/meshes/wood_pallet.mesh"
        materials: [
            PrincipledMaterial {
                baseColorMap: Texture {
                    source: "qrc:/FullScreen3DView/assets/models/eur/textures/wood-pallet.jpg"
                }
                roughness: 1.0
            }
        ]
    }
}
