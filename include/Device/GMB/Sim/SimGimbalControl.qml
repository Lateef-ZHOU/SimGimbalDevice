// SimGimbalControl —— 虚拟云台的「设备控制」分区：电机的两轴限速。
// 定位（前往云台角 / 世界角、停止、标定）在族层那块「状态与定位」（GimbalSection.qml），这里不重复。
import QtQuick
import Lidar.UI
import QtQuick.Controls
import QtQuick.Layouts

Section {
    id: root
    required property SimGimbalDevice device
    // 表单由官邸持有；控件不反向依赖包含自己的具体页面类型。
    required property var settings
    required property var parameters
    title: qsTr("设备控制")

    // 离线只保存输入；在线提交完整两轴，发送失败不接受新值。SliderField 回读原值。
    function commitSpeed(pan: bool, value: real): void {
        const previous = pan ? root.settings.panSpeed : root.settings.tiltSpeed
        if (value === previous) return
        const label = pan ? qsTr("水平速度") : qsTr("俯仰速度")
        if (root.settings.isLocked) {
            root.settings.logMessage(qsTr("设备正被占用，%1未改").arg(label))
            return
        }
        const panSpeed = pan ? value : root.settings.panSpeed
        const tiltSpeed = pan ? root.settings.tiltSpeed : value
        if (root.settings.isOpen && !root.device.setSpeeds(panSpeed, tiltSpeed)) return
        if (pan) root.settings.panSpeed = value
        else root.settings.tiltSpeed = value
        root.settings.logMessage(qsTr("%1：%2 °/s").arg(label).arg(value.toFixed(1)))
    }

    Label { text: qsTr("电机"); font.bold: true }
    FieldRow {
        label: qsTr("水平限速（°/s）")
        SliderField { Layout.fillWidth: true; decimals: 1
                      from: root.parameters.speedStep; to: root.parameters.speedMax
                      stepSize: root.parameters.speedStep
                      value: root.settings.panSpeed
                      onCommitted: function (v) { root.commitSpeed(true, v) } }
    }
    FieldRow {
        label: qsTr("俯仰限速（°/s）")
        SliderField { Layout.fillWidth: true; decimals: 1
                      from: root.parameters.speedStep; to: root.parameters.speedMax
                      stepSize: root.parameters.speedStep
                      value: root.settings.tiltSpeed
                      onCommitted: function (v) { root.commitSpeed(false, v) } }
    }
    Label {
        text: qsTr("两轴各按限速匀速走圆周短程，到点即停，没有加减速段。")
        color: palette.placeholderText
        font.pointSize: 9
        wrapMode: Text.Wrap
        Layout.preferredWidth: 1
        Layout.fillWidth: true
    }
}
