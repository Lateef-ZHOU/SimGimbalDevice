// SimGimbalConnection —— 虚拟云台的「设备连接」分区：没有物理参数，连接就是给虚拟电机上电。
// 主线上虚拟设备不出生即起（2026-10-15 用户定：不一定用，默认起会白占资源）；精简分支由装配根出生时起、不装本分区。
import QtQuick
import Lidar.UI
import QtQuick.Controls
import QtQuick.Layouts

Section {
    id: root
    required property SimGimbalDevice device
    // 表单由官邸持有；控件不反向依赖包含自己的具体页面类型。
    required property var settings
    title: qsTr("设备连接")

    Label {
        text: qsTr("虚拟电机：出生在水平 0°、俯仰 0°，按节拍回报位形；连接即起、断开即停。没有外部设备，连接就是上电。")
        color: palette.placeholderText
        font.pointSize: 9
        wrapMode: Text.Wrap
        Layout.preferredWidth: 1
        Layout.fillWidth: true
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Button { Layout.fillWidth: true; text: qsTr("连接")
                 onClicked: root.device.open(root.settings.panSpeed, root.settings.tiltSpeed) }
        Button { Layout.fillWidth: true; text: qsTr("断开"); onClicked: root.device.close() }
    }
}
