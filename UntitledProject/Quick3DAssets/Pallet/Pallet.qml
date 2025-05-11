import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    property url textureData: "maps/textureData.jpg"
    property url textureData8: "maps/textureData8.jpg"
    Texture {
        id: pallet_fbm_Pallet_BaseColor_jpg_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData
    }
    Texture {
        id: pallet_fbm_Pallet_Normal_jpg_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData8
    }
    PrincipledMaterial {
        id: pallet_material
        baseColor: "#ffcccccc"
        baseColorMap: pallet_fbm_Pallet_BaseColor_jpg_texture
        normalMap: pallet_fbm_Pallet_Normal_jpg_texture
    }

    // Nodes:
    Node {
        id: rootNode
        Model {
            id: pallet
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/plane_001.mesh"
            materials: pallet_material
        }
    }

    // Animations:
}
