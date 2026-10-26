pragma ComponentBehavior: Bound
import QtQuick
import Lidar.UI
import Lidar.TaskUI
import QtQuick.Controls

// 末端页面独持具体型号后端，在这里连接业务、图窗与控制分区。
ModulePage {
    id: root
    readonly property string kind: "device"
    readonly property GMBDeviceBase family: internals.device
    sections: [connectionSection, positioningSection, modelControlSection].filter(item => item !== null)
    function worldHistory(begin, end) { return angles ? angles.worldHistory(begin, end) : undefined }
    function moveParameters() { return ({}) }
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
    readonly property string name: internals.device.device.displayName
    readonly property string subtitle: internals.device.device.subtitle
    readonly property bool isOpen: internals.device.device.isOpen
    readonly property bool isLocked: internals.device.device.isLocked
    readonly property string holder: internals.device.device.holder

    // 连接异步完成：启动期间的编辑仍归 QML，此时把最新值排入电机线程。
    // 对齐失败就关闭本次连接，不能让界面设置与仍在运行的电机限速分离。
    onIsOpenChanged: {
        if (root.isOpen && !internals.device.setSpeeds(root.panSpeed, root.tiltSpeed))
            internals.device.close()
    }

    QtObject {
        id: internals
        readonly property var positioningParameters: device.positioningParameters()
        readonly property SimGimbalDevice device: root.SimGimbalDevice
        readonly property var controlParameters: device.controlParameters()
    }
    Connections {
        target: internals.device.device.logSource
        function onLogMessage(text): void { root.logMessage(text) }
    }
}
