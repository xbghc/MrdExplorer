import QtQuick
import myMrdImageProvider 1.0

Rectangle {
    id: root

    property string path
    property string displayMode: "SLICES" // SINGLE or CHANNELS or SLICES
    property int columns: 4
    property int imageSize: 128
    property int sliceIndex: 0
    property string channelIndex: '1'
    property list<string> channels: []
    property int sliceCount: 0

    // property string test_path: "image://mrd/C:/Projects/MRI-ANC/data/1/exp2/20220413101349-T1-s#1.mrd"

    Component.onCompleted:
    // console.log(imageViewer.sourceMap);
    // imageViewer.sourceMap = [["image://mrd/C:/Projects/MRI-ANC/data/1/exp3/1/0"]];
    {}

    ImageViewer {
        id: imageViewer
        anchors.fill: parent

        imageSize: root.imageSize
        // sourceMap: [["image://mrd/C:/Projects/MRI-ANC/data/1/exp2/20220413101349-T1-s#1.mrd/1/0"]]
        // sourceMap: [["image://mrd/C:/Projects/MRI-ANC/data/1/exp2/1/0"]]
    }

    Connections {
        target: imageBridge
        function onChannelsChanged(channels) {
            root.channels = channels;
        }
        function onSlicesChanged(sliceCount) {
            root.sliceCount = sliceCount;
            root.updateSourceMap(root.path);
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

    function updateSourceMap(newPath) {
        if (displayMode == "SLICES") {
            var sourceMap = [];
            var rowCount = Math.ceil(sliceCount / columns);
            for (var i = 0; i < rowCount; i++) {
                var row = [];
                for (var j = 0; j < columns; j++) {
                    var slice = i * columns + j;
                    if (slice < sliceCount) {
                        row.push("image://mrd/" + newPath + "/" + channelIndex + "/" + slice);
                    }
                }
                sourceMap.push(row);
            }
            imageViewer.setSourceMap(sourceMap);
        } else if (displayMode === "CHANNELS") {
            imageViewer.sourceMap = [];
            for (var i = 0; i < columns; i++) {
                var column = [];
                for (var j = 0; j < columns; j++) {
                    column.push("image://mrd/" + path + "/" + (channelIndex + i * columns + j) + "/" + sliceIndex);
                }
                imageViewer.sourceMap.push(column);
            }
        } else if (displayMode === "SINGLE") {
            imageViewer.sourceMap = [];
            imageViewer.sourceMap.push(["image://mrd/" + path]);
        }
    } // updateSourceMap
}
