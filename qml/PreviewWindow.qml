import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: previewWindow
    width: 1000
    height: 800
    visible: true
    title: "Preview JSON"
    color: "#f7f7f7"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "JSON Preview Summary"
            font.bold: true
            font.pixelSize: 24
            color: "#222"
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Raw JSON Data Panel
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Text {
                    text: "Raw JSON"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#444"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: mainWindow.getRawJson()
                        wrapMode: Text.Wrap
                        font.pixelSize: 14
                        color: "#333"
                    }
                }
            }

            // Invalid Boxes Panel
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Text {
                    text: "Invalid Boxes"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#444"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: mainWindow.getInvalidBoxesSummary()
                        wrapMode: Text.Wrap
                        font.pixelSize: 14
                        color: "red"
                        font.bold: true
                    }
                }
            }
        }

        Button {
            text: "Close"
            Layout.alignment: Qt.AlignRight
            onClicked: previewWindow.close()
        }
    }
}
