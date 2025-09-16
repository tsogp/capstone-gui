import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D

Dialog {
    id: boxDialog
    modal: true
    title: "Configure Boxes"
    width: parent.width
    height: parent.height

    property var boxes: ({})
    property var boxArray: []

    property real boxWidth: 0
    property real boxHeight: 0
    property real boxLength: 0
    property real boxWeight: 0
    property real boxMaxLoad: 0
    property int boxAmount: 0

    property bool valid: boxWidth > 0 && boxHeight > 0 && boxLength > 0 && boxWeight > 0 && boxMaxLoad > 0 && boxAmount > 0

    footer: DialogButtonBox {
        standardButtons: Dialog.Close
        Button {
            text: "Confirm"
            enabled: boxArray.length > 0
            onClicked: {
                mainWindow.processBoxesManual(boxArray)
                boxDialog.close()
            }
        }
        onRejected: boxDialog.close()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        ColumnLayout {
            Layout.preferredWidth: 250
            spacing: 8

            Label {
                text: "Width (cm)"
            }
            SpinBox {
                width: parent.width
                from: 1
                to: 1000
                editable: true
                value: boxDialog.boxWidth
                onValueChanged: boxDialog.boxWidth = value
            }

            Label {
                text: "Height (cm)"
            }
            SpinBox {
                from: 1
                to: 1000
                editable: true
                value: boxDialog.boxHeight
                onValueChanged: boxDialog.boxHeight = value
            }

            Label {
                text: "Length (cm)"
            }
            SpinBox {
                from: 1
                to: 1000
                editable: true
                value: boxDialog.boxLength
                onValueChanged: boxDialog.boxLength = value
            }

            Label {
                text: "Weight (kg)"
            }
            SpinBox {
                from: 1
                to: 10000
                editable: true
                value: boxDialog.boxWeight
                onValueChanged: boxDialog.boxWeight = value
            }

            Label {
                text: "Max Load (kg)"
            }
            SpinBox {
                from: 1
                to: 50000
                editable: true
                value: boxDialog.boxMaxLoad
                onValueChanged: boxDialog.boxMaxLoad = value
            }

            Label {
                text: "Amount"
            }
            SpinBox {
                from: 1
                to: 100
                editable: true
                value: boxDialog.boxAmount
                onValueChanged: boxDialog.boxAmount = value
            }

            Button {
                text: "Add Box"
                enabled: boxDialog.valid
                onClicked: {
                    const hash = boxWidth + "_" + boxHeight + "_" + boxLength + "_" + boxWeight + "_" + boxMaxLoad;
                    if (hash in boxes) {
                        boxes[hash].amount += boxAmount;
                    } else {
                        boxes[hash] = {
                            w: boxWidth,
                            h: boxHeight,
                            l: boxLength,
                            weight: boxWeight,
                            max_load: boxMaxLoad,
                            amount: boxAmount
                        };
                    }
                    boxArray = Object.values(boxes);
                    console.log("Boxes now:", JSON.stringify(boxArray));
                }
            }
        }

        View3D {
            id: view3d
            Layout.fillWidth: true
            Layout.fillHeight: true
            property real rotationX: 0
            property real rotationY: 0

            environment: SceneEnvironment {
                clearColor: "lightgray"
                backgroundMode: SceneEnvironment.Color
            }

            PerspectiveCamera {
                id: camera
                position: Qt.vector3d(0, 200, 400)
                eulerRotation.x: -30
            }

            DirectionalLight {
                eulerRotation: Qt.vector3d(-45, -45, 0)
                brightness: 1.2
            }

            Model {
                id: boxModel
                source: "#Cube"
                scale: Qt.vector3d(boxDialog.boxWidth / 5, boxDialog.boxHeight / 5, boxDialog.boxLength / 5)
                materials: DefaultMaterial {
                    diffuseColor: "dodgerblue"
                }
                eulerRotation: Qt.vector3d(view3d.rotationX, view3d.rotationY, 0)
            }

            MouseArea {
                anchors.fill: parent
                property real lastX: 0
                property real lastY: 0
                onPressed: mouse => {
                    lastX = mouse.x;
                    lastY = mouse.y;
                }
                onPositionChanged: mouse => {
                    var dx = mouse.x - lastX;
                    var dy = mouse.y - lastY;
                    view3d.rotationY += dx * 0.5;
                    view3d.rotationX += dy * 0.5;
                    if (view3d.rotationX > 90)
                        view3d.rotationX = 90;
                    if (view3d.rotationX < -90)
                        view3d.rotationX = -90;
                    boxModel.eulerRotation = Qt.vector3d(view3d.rotationX, view3d.rotationY, 0);
                    lastX = mouse.x;
                    lastY = mouse.y;
                }
            }
        }

        Item {
            Layout.preferredWidth: 400
            Layout.fillHeight: true

            ListView {
                id: boxesList
                anchors.fill: parent
                model: boxArray

                delegate: RowLayout {
                    width: boxesList.width
                    spacing: 8
                    anchors.margins: 8

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "Box " + (index + 1) + ": " + modelData.w + " × " + modelData.h + " × " + modelData.h + " cm"
                            font.bold: true
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Amount: " + modelData.amount + " | Weight: " + modelData.weight + " kg" + " | Max Load: " + modelData.max_load + " kg"
                            font.pixelSize: 12
                            color: "#555"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }   // spacer

                    Button {
                        text: "✖"
                        onClicked: {
                            console.log("Deleting", modelData);
                            const hash = modelData.w + "_" + modelData.h + "_" + modelData.h + "_" + modelData.weight + "_" + modelData.max_load;
                            delete boxes[hash];
                            boxArray = Object.values(boxes);
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: "No boxes added yet"
                color: "gray"
                visible: boxArray.length === 0
            }
        }
    }
}
