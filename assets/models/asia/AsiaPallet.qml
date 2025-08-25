import QtQuick
import QtQuick3D

Node {
    id: root

    property url woodTextureUrl: "qrc:/FullScreen3DView/assets/models/maps/wood.jpg"
    property url metalnessRoughnessTextureUrl: "qrc:/FullScreen3DView/assets/models/maps/metalness-map.png"
    property url normalMapTextureUrl: "qrc:/FullScreen3DView/assets/models/maps/normal-map.png"

    Texture {
        id: colorMapTexture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: root.woodTextureUrl
    }

    Texture {
        id: metalnessRoughnessTexture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: root.metalnessRoughnessTextureUrl
    }

    Texture {
        id: normalMapTexture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: root.normalMapTextureUrl
    }

    PrincipledMaterial {
        id: wood_1_material2
        baseColorMap: colorMapTexture
        metalnessMap: metalnessRoughnessTexture
        roughnessMap: metalnessRoughnessTexture
        roughness: 1
        normalMap: normalMapTexture
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }

    Model {
        id: cube_0011
        source: "meshes/mesh.mesh"
        scale: Qt.vector3d(1.55, 1.55, 1.55)
        materials: [wood_1_material2, wood_1_material2]
    }
}
