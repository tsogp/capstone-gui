import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    Texture {
        id: europalette_fbm_Euro_pallet_New_BaseColor_4K_exr_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        // Source texture path expected: maps/Euro_pallet_New_BaseColor_4K.exr
        // Skipped property: source, reason: Failed to find texture at /home/tsogp/schul/2025/sem1/capstone/gui/UntitledProject/assets/EUROPALETTE.fbm/Euro_pallet_New_BaseColor_4K.exr
    }

    // Nodes:
    Node {
        id: rootNode
        Model {
            id: board_01_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_012.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: board_05_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_011.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: board_03_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_007.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: board_02_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_006.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: board_04_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_005.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: top_ELEMENT_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_004.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: middle_ELEMNT_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_003.mesh"
            materials: eur_Pallet_New_material
        }
        Model {
            id: bottom_ELEMENT_SUB0
            rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
            scale.x: 100
            scale.y: 100
            scale.z: 100
            source: "meshes/cube_002.mesh"
            materials: eur_Pallet_New_material
        }
    }

    Node {
        id: __materialLibrary__

        PrincipledMaterial {
            id: eur_Pallet_New_material
            objectName: "eur_Pallet_New_material"
            baseColor: "#ffcccccc"
            baseColorMap: europalette_fbm_Euro_pallet_New_BaseColor_4K_exr_texture
        }
    }

    // Animations:
}
