pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform

Rectangle {
    id: root

    signal folderChangedSignal(string folderPath)

    // dispaly mode有三种模式
    // 1. FILE: 文件模式
    // 2. FOLDER: 文件夹模式
    signal displayModeChangedSignal(string mode)
    
    property string displayMode: "FOLDER"

    color: "lightgray"

    function openFolder(folderPath) {
        fileModel.folder = folderPath;
    }

    RowLayout {
        id: header

        width: root.width
        height: 50

        RadioButton {
            id: radio1

            text: "按文件"
            checked: root.displayMode === "FILE"
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 10

            onClicked: {
                root.displayMode = "FILE";
                root.displayModeChangedSignal("FILE");
            }
        }

        RadioButton {
            id: radio2

            text: "按文件夹"
            checked: root.displayMode === "FOLDER"
            Layout.alignment: Qt.AlignVCenter

            onClicked: {
                root.displayMode = "FOLDER";
                root.displayModeChangedSignal("FOLDER");
            }
        }

        Button {
            text: "选择目录"
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            onClicked: {
                folderDialog.open();
            } // onClicked

            FolderDialog {
                id: folderDialog
                title: "选择文件夹"

                onAccepted: {
                    root.openFolder(currentFolder);
                    root.folderChangedSignal(currentFolder);
                }
            }
        }
    }

    ListView {
        id: listView

        width: root.width
        height: root.height - header.height
        anchors.top: header.bottom

        model: FileModel {
            id: fileModel

            showDirs: root.displayMode === "FOLDER"
            showFiles: root.displayMode === "FILE"
        }
        delegate: Rectangle {
            id: delegate
        required property string index  // 显式声明必需的属性
        required property string fileName  // 显式声明必需的属性
        width: listView.width
        height: 50

        color: ListView.isCurrentItem ? "lightblue" : "white"

        Text {
            text: delegate.fileName  // 使用声明的属性
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: listView.currentIndex = delegate.index
        }
    } 
    }

}
