// ThreeDView.qml
import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Item {
    id: root

    readonly property vector3d cameraPosition: Qt.vector3d(0, 10, 300)
    readonly property vector3d lightRotation: Qt.vector3d(-25.34759, -2.67751, -19.212)

    property alias view: view3D

    property vector3d palletRotation: Qt.vector3d(15, 70, 30)
    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"
    property string boxSource: "qrc:/FullScreen3DView/assets/models/box/CartonBox.qml"

    Component.onCompleted: {
        let boxes = threeDSpaceView.getSpawnedBoxes();
        for (let i = 0; i < boxes.length; ++i) {
            spawnBoxInQML(boxes[i].position, palletRotation, boxes[i].scaleFactor, boxes[i].id);
        }
    }

    View3D {
        id: view3D
        anchors.fill: parent

        property var selectedBox: null

        environment: SceneEnvironment {
            id: sceneEnvironment
            clearColor: "white"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) {
                var result = view3D.pick(mouse.x, mouse.y);

                if (result.objectHit) {
                    var pickedModel = result.objectHit;
                    var boxNode = pickedModel.parent;

                    // Deselect previously selected box
                    if (view3D.selectedBox && view3D.selectedBox !== boxNode) {
                        view3D.selectedBox.model.isPicked = false;
                    }

                    // Mark the new box as selected
                    pickedModel.isPicked = true;
                    view3D.selectedBox = boxNode;
                    mainWindow.updateBoxInfo(boxNode.boxId);
                }
            }
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
            source: threeDSpaceView.currentModelSource
            active: true
            asynchronous: true

            onLoaded: {
                item.position = Qt.vector3d(0, 30, 0);
                item.eulerRotation = palletRotation;
                item.scale = Qt.vector3d(1.5, 1.5, 1.5);
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
            let box = threeDSpaceView.getNewBox();
            spawnBoxInQML(box.position, palletRotation, box.scaleFactor, box.id);
            console.log("Box spawned with ID:", box.id, "Weight:", box.weight, "Max Load:", box.maxLoad);
        }
    }

    function spawnBoxInQML(position, rotation, scale, id) {
        // TODO: remove, for debugging only
        console.log("Spawning box at", position, "with rotation", rotation, "with scale", scale);
        var component = Qt.createComponent(boxSource);
        if (component.status === Component.Ready) {
            var box = component.createObject(shapeSpawner, {
                "position": position,
                "eulerRotation": rotation,
                "scale": scale,
                "boxId": id
            });
            if (!box) {
                console.error("Failed to create box");
            }
        } else {
            console.error("Box component error:", component.errorString());
        }
    }
}
