pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import main.backend 1.0

Rectangle {
    id: root

    signal fileChanged(string url)

    property bool mergeChannels: true
    property alias hideSingle: hideSingleCheckBox.checked
    property string folder: ""

    function openFolder(folderPath) {
        folder = folderPath;
        listView.model = Backend.listdir(folderPath, mergeChannels, hideSingle);  // qmllint disable unqualified
        textField.text = folderPath;
    }

    function openParentFolder() {
        var newPath = folder.substring(0, folder.lastIndexOf('/'));
        openFolder(newPath);
    }

    Component.onCompleted: {
        openFolder("C:/Projects/MRI-ANC/patients")
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.topMargin: 10

        CheckBox {
            id: hideSingleCheckBox

            checked: true
            text: qsTr("Hide Single-Channel Scan")

            Layout.leftMargin: 5
        }

        RowLayout {
            id: header
            width: root.width
            height: 50
            Layout.leftMargin: 5

            Button {
                text: qsTr("<")

                onClicked: {
                    root.openParentFolder();
                }
            }

            TextField {
                id: textField

                onAccepted: {}

                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Change Folder")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                onClicked: {
                    folderDialog.open();
                }

                FolderDialog {
                    id: folderDialog
                    title: "Select Folder"

                    onAccepted: {
                        let p = currentFolder.toString().replace("file:///", "");
                        root.openFolder(p);
                    }
                }
            }
        } // RowLayout header

        ListView {
            id: listView

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            ScrollBar.vertical: ScrollBar {
                id: vbar
                active: listView.moving || pressed
                policy: ScrollBar.AsNeeded
            }

            delegate: Rectangle {
                id: delegate

                required property int index
                required property string filename
                required property bool isDir
                required property string url

                width: ListView.view.width
                height: 50
                color: ListView.isCurrentItem ? "lightblue" : "lightgray"

                Text {
                    text: delegate.filename

                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    color: delegate.isDir ? "brown" : "black"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (delegate.isDir) {
                            root.openFolder(delegate.url);
                        } else {
                            root.fileChanged(delegate.url);
                            listView.currentIndex = delegate.index;
                        }
                    }
                }
            }
        }
    }
}
