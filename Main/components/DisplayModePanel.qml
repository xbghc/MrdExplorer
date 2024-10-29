import QtQuick
import QtQuick.Controls

Column {
    id: root

    property int childHeight: 40
    signal displayModeChangedSignal(string mode)
    signal sliceFilterChangedSignal(int sliceIndex)
    signal channelFilterChangedSignal(string channelIndex)

    ButtonGroup {
        id: buttonGroup
    }

    Row {
        height: root.childHeight
        RadioButton {
            id: allRadioButton
            text: "全部显示"
            checked: true

            ButtonGroup.group: buttonGroup
            onClicked: {
                root.displayModeChangedSignal("ALL");
            }
        }
    }

    Row {
        height: root.childHeight
        RadioButton {
            id: singleSliceRadioButton
            text: "单切片多通道"
            ButtonGroup.group: buttonGroup
            onClicked: {
                root.displayModeChangedSignal("SINGLE_SLICE");
            }
        }
        ComboBox {
            id: sliceFilterComboBox
            visible: singleSliceRadioButton.checked
            onActivated: {
                root.sliceFilterChangedSignal(sliceFilterComboBox.currentText);
            }
        }
    }

    Row {
        height: root.childHeight
        RadioButton {
            id: singleChannelRadioButton
            text: "单通道多切片"
            ButtonGroup.group: buttonGroup
            onClicked: {
                root.displayModeChangedSignal("SINGLE_CHANNEL");
            }
        }

        ComboBox {
            id: channelFliterComboBox
            visible: singleChannelRadioButton.checked
            onActivated: {
                root.channelFilterChangedSignal(channelFliterComboBox.currentText);
            }
        }
    }

    Connections {
        target: imageBridge  // qmllint disable unqualified
        function onImagesChanged(channels, sliceCount) {
            sliceFilterComboBox.model = sliceCount;
            channelFliterComboBox.model = channels;
        }
    }
}
