import QtQuick
import myMrdImageProvider 1.0

Rectangle {
    id: root

    property string path
    property int columns: 4
    property int imageSize: 128
    property int sliceIndex: 0
    property string channelIndex: '1'
    property var channels: []
    property int sliceCount: 0
    property string displayMode: "ALL"

    ImageViewer {
        id: imageViewer
        anchors.fill: parent

        imageSize: root.imageSize
    }

    Connections {
        target: imageBridge
        function onImagesChanged(channels, sliceCount) {
            root.channels = channels;
            root.sliceCount = sliceCount;
            root.updateSourceMap();
        }
    }

    function setFolder(newPath) {
        newPath = newPath.replace("file:///", "");
        root.path = newPath;

        // 促使imageProvider重新加载图片
        triggerImage.source = "image://mrd/" + newPath + "/1/0";
    }

    Image {
        id: triggerImage
        visible: false
    }

    function updateSourceMap() {
        if (displayMode == "SLICES") {
            var sourceMap = [];
            var rowCount = Math.ceil(sliceCount / columns);
            for (var i = 0; i < rowCount; i++) {
                var row = [];
                for (var j = 0; j < columns; j++) {
                    var slice = i * columns + j;
                    if (slice < sliceCount) {
                        row.push("image://mrd/" + root.path + "/" + channelIndex + "/" + slice);
                    }
                }
                sourceMap.push(row);
            }
            imageViewer.setSourceMap(sourceMap);
        } else if (displayMode == "CHANNELS") {
            var sourceMap = [];
            var rowCount = Math.ceil(channels.length / columns);
            for (var i = 0; i < rowCount; i++) {
                var row = [];
                for (var j = 0; j < columns; j++) {
                    var channel = i * columns + j;
                    if (channel < channels.length) {
                        row.push("image://mrd/" + root.path + "/" + channels[channel] + "/" + sliceIndex);
                    }
                }
                sourceMap.push(row);
            }
            imageViewer.setSourceMap(sourceMap);
        } else if (displayMode == "ALL") {
            var sourceMap = [];
            for (var i = 0; i < root.sliceCount; i++) {
                var row = [];
                for (var j = 0; j < root.channels.length; j++) {
                    row.push("image://mrd/" + root.path + "/" + root.channels[j] + "/" + i);
                }
                sourceMap.push(row);
            }
            imageViewer.setSourceMap(sourceMap);
        } else {
            // 抛出异常
            throw new Error("Invalid display mode: " + displayMode);
        }
    } // updateSourceMap
}
