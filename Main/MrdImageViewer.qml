/*
    MrdImageViewer使用ImageViewer显示图片，
    它根据外部传入的参数来调整对ImageViewer的调用。
    所需的参数包括
    1. path：字符串，图片文件或其所在文件夹的目录
    2. displayMode：字符串，显示模式可以是"ALL"、"CHANNELS"或"SLICES"
    注意，path并非直接传递给MrdImageViewer，而是通过setFolder方法传递给它。

    当外部调用setFolder，MrdImageViewer会经历以下步骤：
    1. 让imageProvider重新加载图片
    2. imageProvider返回通道列表channels和切片数sliceCount
    3. MrdImageViewer生成sourceMap
    之所以要让imageProvider返回通道列表后才生成sourceMap，
    是因为当displayMode是ALL的时候，需要知道通道和切片的数量才能列举所有的图片

    由于channels可能不连续，所以设置channel的索引类型为字符串，用字典索引。
    而slices是连续的，所以设置slice的类型为整数，用数组索引。
    因为ImageViewer使用Repeater来生成图片，不能接受字典，所以传给它的是字典中keys的数组。
*/

import QtQuick

Rectangle {
    id: root

    property string path: ""
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
    
    Image {
        id: triggerImage
        visible: false
    }

    Connections {
        target: imageBridge  // qmllint disable unqualified
        function onImagesChanged(channels, sliceCount) {
            root.channels = channels;
            root.sliceCount = sliceCount;
            root.updateSourceMap();
        }
    }

    function setFolder(newPath) {
        const cleanPath = newPath.replace("file:///", "");
        root.path = cleanPath;
        // 促使imageProvider重新加载图片
        triggerImage.source = `image://mrd/${cleanPath}/1/0`;
    }

    function generateImageUrl(channelId, sliceId) {
        return `image://mrd/${root.path}/${channelId}/${sliceId}`;
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
                        row.push(generateImageUrl(channelIndex, slice));
                    }
                }
                sourceMap.push(row);
            }
            imageViewer.sourceMap = sourceMap;
        } else if (displayMode == "CHANNELS") {
            var sourceMap = [];
            var rowCount = Math.ceil(channels.length / columns);
            for (var i = 0; i < rowCount; i++) {
                var row = [];
                for (var j = 0; j < columns; j++) {
                    var channel = i * columns + j;
                    if (channel < channels.length) {
                        row.push(generateImageUrl(channels[channel], sliceIndex));
                    }
                }
                sourceMap.push(row);
            }
            imageViewer.sourceMap = sourceMap;
        } else if (displayMode == "ALL") {
            var sourceMap = [];
            for (var i = 0; i < root.sliceCount; i++) {
                var row = [];
                for (var j = 0; j < root.channels.length; j++) {
                    row.push(generateImageUrl(root.channels[j], i));
                }
                sourceMap.push(row);
            }
            imageViewer.sourceMap = sourceMap;
        } else {
            // 抛出异常
            throw new Error("Invalid display mode: " + displayMode);
        }
    } // updateSourceMap

}
