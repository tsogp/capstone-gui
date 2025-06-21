import QtQuick
import QtQuick3D

Node {
    id: indPallet

    Model {
        id: indPalletModel
        source: "meshes/ind_pallet.mesh"
        scale: Qt.vector3d(50, 50, 50)
        materials: [
            PrincipledMaterial {
                id: cartonBoxDefaultMaterial
                baseColorMap: Texture {
                    source: "qrc:/FullScreen3DView/assets/models/ind/textures/ind_pallet.jpg"
                }
                roughness: 1
                metalness: 0.1
                indexOfRefraction: 1
            }
        ]
    }
}