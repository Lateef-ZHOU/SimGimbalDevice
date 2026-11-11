pragma ComponentBehavior: Bound
import QtQuick
import Lidar.UI
import Lidar.TaskUI
import QtQuick.Controls

// 末端页面独持具体型号后端，在这里连接业务、图窗与控制分区。
ModulePage {
    id: root
    readonly property string kind: "device"
    readonly property QtObject family: internals.device // 云台族基不是 QObject，交出设备对象本身
    sections: [connectionSection, positioningSection, modelControlSection].filter(item => item !== null)
    function worldHistory(begin, end) { return angles ? angles.worldHistory(begin, end) : undefined }
    property real panSpeed: internals.controlParameters.panSpeedDefault
    property real tiltSpeed: internals.controlParameters.tiltSpeedDefault
    mainPages: [Page {
        title: qsTr("角度")
        contentItem: GimbalCharts {
            id: angles
            device: internals.device
            configuration: internals.device.chartParameters().configuration
        }
    }]
    readonly property Section connectionSection: SimGimbalConnection {
        device: internals.device
        settings: root
    }
    readonly property Section positioningSection: GimbalSection {
        device: internals.device
        settings: root
        panMin: internals.positioningParameters.panMin
        panMax: internals.positioningParameters.panMax
        tiltMin: internals.positioningParameters.tiltMin
        tiltMax: internals.positioningParameters.tiltMax
    }
    readonly property Section modelControlSection: SimGimbalControl {
        device: internals.device
        settings: root
        parameters: internals.controlParameters
    }
    objectName: "SimGimbalModule"
    readonly property string name: internals.device.displayName
    readonly property string subtitle: internals.device.subtitle
    // 借用公共只读资源接口（即设备对象本身），不另存状态。
    readonly property var deviceState: internals.device

    // 连接异步完成：启动期间的编辑仍归 QML，此时把最新值排入电机线程。
    // 对齐失败就关闭本次连接，不能让界面设置与仍在运行的电机限速分离。
    Connections {
        target: root.deviceState
        function onConnectionChanged(phase): void {
            if (phase === ResourcePhase.Acquired && root.deviceState.isOpen
                && !internals.device.setSpeeds(root.panSpeed, root.tiltSpeed))
                internals.device.close()
        }
    }

    QtObject {
        id: internals
        readonly property var positioningParameters: device.positioningParameters()
        readonly property SimGimbalDevice device: root.SimGimbalDevice
        readonly property var controlParameters: device.controlParameters()
    }
    Connections {
        target: internals.device
        function onLogMessage(text): void { root.logMessage(text) }
    }
}
