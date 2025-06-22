// ThreeDView.qml
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Item {
    id: root
    property alias view: view3D

    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"

    View3D {
        id: view3D
        anchors.fill: parent

        environment: SceneEnvironment {
            id: sceneEnvironment
            clearColor: "white"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 10, 300)
            clipNear: 1.0
        }

        DirectionalLight {
            position: Qt.vector3d(0, 430, 900)
            brightness: 1
            eulerRotation.z: -19.212
            eulerRotation.x: -25.34759
            eulerRotation.y: -2.67751
            ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
        }

        Loader3D {
            id: palletLoader
            source: currentModelSource
            active: true

            onLoaded: {
                item.position = Qt.vector3d(0, 30, 0)
                item.eulerRotation = Qt.vector3d(15, 70, 30)
                item.scale = Qt.vector3d(1.5, 1.5, 1.5)
            }
        }
    }
}
