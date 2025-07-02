// ThreeDView.qml
import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Item {
    id: root

    readonly property vector3d cameraPosition: Qt.vector3d(0, 10, 300)
    readonly property vector3d palletRotation: Qt.vector3d(15, 70, 30)
    readonly property vector3d lightRotation: Qt.vector3d(-25.34759, -2.67751, -19.212)

    property vector3d newBoxPosition: threeDSpaceView.newBoxPosition
    property vector3d newBoxRotation: palletRotation
    property vector3d newBoxScaleFactor: threeDSpaceView.newBoxScaleFactor

    property alias view: view3D
    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"
    property string boxSource: "qrc:/FullScreen3DView/assets/models/box/CartonBox.qml"

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
            position: cameraPosition
            clipNear: 1.0
        }

        DirectionalLight {
            position: Qt.vector3d(0, 430, 900)
            brightness: 1
            eulerRotation.x: lightRotation.x
            eulerRotation.y: lightRotation.y
            eulerRotation.z: lightRotation.z
            ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
        }

        Loader3D {
            id: palletLoader
            objectName: "palletLoader"
            source: currentModelSource
            active: true

            onLoaded: {
                item.position = Qt.vector3d(0, 30, 0)
                item.eulerRotation = palletRotation
                item.scale = Qt.vector3d(1.5, 1.5, 1.5)
            }
        }

        Node {
            id: shapeSpawner
            position: Qt.vector3d(0, 30, 0)
            objectName: "shapeSpawner"
        }
    }

    // TODO: remove, for debugging only
    Button {
        id: spawnBoxButton
        text: "Spawn Box"
        width: 120
        height: 40
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 16
        }

        onClicked: {
            threeDSpaceView.genCoordinatesForNextBox()
            spawnBoxInQML(newBoxPosition, newBoxRotation, newBoxScaleFactor)
        }
    }

    function spawnBoxInQML(position, rotation, scale) {
        // TODO: remove, for debugging only
        console.log("Spawning box at", position, "with rotation", rotation, "with scale", scale)
        var component = Qt.createComponent(boxSource);
        if (component.status === Component.Ready) {
            var box = component.createObject(shapeSpawner, {
                "position": position,
                "eulerRotation": rotation,
                "scale": scale
            });
            if (!box) {
                console.error("Failed to create box");
            }
        } else {
            console.error("Box component error:", component.errorString());
        }
    }
}
