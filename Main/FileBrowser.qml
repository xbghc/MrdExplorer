import QtQuick

Rectangle{
    id: root

    signal fileSelected(string filePath)
    signal folderSelected(string folderPath)
    signal displayModeChanged(bool fileMode, bool folderMode, bool scanMode)

    color: "lightgray"

    Text{
        id: title
        text: "File Browser"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListView{
        id: listView
        width: root.width
        height: root.height - 50
        anchors.top: title.bottom
        model: FileModel{
            id: fileModel
        }
        delegate: Item{
            width: listView.width
            height: 50
            Rectangle{
                width: listView.width
                height: 50
                color: listView.currentIndex === index ? "lightblue" : "white"
                Text{
                    text: fileName
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: listView.currentIndex = index
                }
            }
        }
    }
}