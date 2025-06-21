import QtQuick
import QtQuick3D

Node {
    id: asiaPallet

    Model {
        id: asiaPalletModel
        source: "meshes/asia_pallet.mesh"
        eulerRotation: Qt.vector3d(-90, -45, 45)
        materials: [
            PrincipledMaterial {
                id: cartonBoxDefaultMaterial
                baseColorMap: Texture {
                    source: "qrc:/FullScreen3DView/assets/models/asia/textures/asia_pallet.png"
                }
                roughness: 1
                indexOfRefraction: 1
            }
        ]
    }
}