import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 800

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: controlPanel
            Layout.fillHeight: true
            Layout.preferredWidth: 300

            FileBrowser {
                id: fileBrowser
                width: controlPanel.width
                height: 260
            }

            Row {
                id: displayModePanel
                anchors.topMargin: 50
                anchors.top: fileBrowser.bottom
                width: controlPanel.width
                height: 40
                RadioButton {
                    id: allRadioButton
                    text: "全部显示"
                    checked: true
                    onClicked: {
                        imageViewer.displayMode = "ALL";
                        imageViewer.updateSourceMap();
                    }
                }
                RadioButton {
                    id: channelsRadioButton
                    text: "显示所有通道"
                    onClicked: {
                        imageViewer.displayMode = "CHANNELS";
                        imageViewer.updateSourceMap();
                    }
                }
                RadioButton {
                    id: slicesRadioButton
                    text: "显示所有切片"
                    onClicked: {
                        imageViewer.displayMode = "SLICES";
                        imageViewer.updateSourceMap();
                    }
                }
            }
        }

        Rectangle {
            id: screen

            Layout.fillWidth: true
            Layout.fillHeight: true

            MrdImageViewer {
                id: imageViewer

                anchors.fill: parent
                imageSize: 128
            }
        }
    }

    Connections {
        target: fileBrowser
        function onItemSelectedSignal(newPath) {
            imageViewer.setFolder(newPath);
        }
    }
}
