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

            DisplayModePanel {
                id: displayModePanel
                
                anchors.topMargin: 50
                anchors.top: fileBrowser.bottom
                width: controlPanel.width
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

    Connections {
        target: displayModePanel
        function onDisplayModeChangedSignal(mode) {
            imageViewer.displayMode = mode;
            imageViewer.updateSourceMap();
        }
        function onSliceFilterChangedSignal(sliceIndex) {
            imageViewer.sliceIndex = sliceIndex;
            imageViewer.updateSourceMap();
        }
        function onChannelFilterChangedSignal(channelIndex) {
            imageViewer.channelIndex = channelIndex;
            imageViewer.updateSourceMap();
        }
    }
}
