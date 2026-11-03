# SimGimbalDevice

2026-11-03 上传接口：官邸仍拥有唯一具体 Core；Core 继承 `Device<HandleT, CollectorT>`，Device 直接继承 Handle 并重写 onData。Core 只提供 Qt 属性、锁信号与末端预析构；不增设上传回调、状态缓存或逐包信号转发。协议、Collector 与 UI 逻辑保持。

LiDAR 的独立官邸：具体 C++ 后端、Collector/协议/处理逻辑及其 QML 页面在同一仓库维护。来自 LiDAR_DataACQ master `5cc6d65`，分仓后的全功能入口保持原行为。

## 边界与接入

- QML 模块：`Lidar.SimGimbal`；页面：`SimGimbalModule`。
- CMake 目标：`Lidar::SimGimbalDevice`；静态插件：`LidarSimGimbalDeviceplugin`，最终可执行文件显式 `Q_IMPORT_QML_PLUGIN(LidarSimGimbalDevicePlugin)`，并导入 TaskUI/UI/Charts 的静态插件。
- 页面以 attached 对象拥有唯一具体后端，后端不能在 QML 直接创建。设备通过只读 `family` 借出族引用；任务页面只接收族列表，不依赖设备官邸。
- 依赖由 `cmake/Dependencies.cmake` 固定到提交；可用标准 FetchContent 源码覆盖做联调。多个官邸并用时，先开启所有需要的 HandleCore/TaskCore 可选项，再配置共享库，避免已创建目标后补开模块。
- 不需要串口、抓包驱动。

## 构建与验证

C++20、CMake >= 3.28、Qt 6.11.2（Quick/Qml/GuiPrivate/ShaderTools）。Windows 使用 MSVC x64；Linux 使用 GCC，Qt 与原生依赖由环境提供。

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="<Qt前缀;需要的原生依赖前缀>"
cmake --build build --config Release --parallel 2
ctest --test-dir build -C Release --output-on-failure
cmake --build build --config Release --target LidarSimGimbalDevice_qmllint
```

独立测试逐头编译、创建真实页面并销毁后端；不连接实物设备。硬件收发仍需对应设备实测。主程序负责跨官邸仿真、任务及取消链回归。

## 许可

MIT，Copyright (c) 2026 周涛（ZHOU TAO）。Qt、libserialport、libpcap/Npcap 等依赖各自授权，MIT 不替代这些许可；详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。本仓库不包含第三方 SDK、运行库或驱动。

## 两套 QML 官邸（2026-10-27）

同一 QML 模块同时提供 `SimGimbalModule`（全功能）和 `SimGimbalSimOnlyModule`（数字样机）。每个页面以 Qt attached 机制拥有唯一的同类型 C++ 后端，没有第二套设备/任务实现。全功能主程序继续使用原入口。

simonly 页面保留角度历史、安装姿态、定位和两轴限速，不提供连接栏。应用先调用 applyConfiguration，再调用 open；不在页面构造中抢先连接。configuration/configurationChanged 供应用读写 JSON，页面不持文件或配置副本。

[LiDAR_DataACQ-simonly](https://github.com/Lateef-ZHOU/LiDAR_DataACQ-simonly) 通过固定版本装配这些入口，负责 JSON、命令行、设备就绪后启动和系统信号取消。窗口隐藏仍保留历史，不触发实际绘制。测试创建两套真实页面并检查后端唯一性、销毁和精简分区；跨设备的三任务采样与保存由应用集成测试覆盖。

## 资源阶段通知（2026-11-02）

连接采用 HandleCore 的 `connectionChanged(ResourcePhase)`；主动关闭前在所属线程同步发 `AboutToRelease`，完成事件用于回读现状。页面借出已有 `deviceState` 机制对象，不再保存 isOpen/isLocked/holder 的 QML 转交属性；标签通过连接/锁完成阶段回读，不恢复通用 statusChanged。固定依赖已同步；本轮提交尚未推送，验证使用显式本地源码覆盖。
首次连接和重连的 `Acquired` 到达时按实际连接回读并同步页面速度；原占用时拒改和同步失败关闭规则保留。


2026-11-03 验证：Windows Qt 6.11.2 主程序 Release 编译、15 组 QML 检查、跨官邸生命周期和三任务回归 7/7 通过。接口联调使用相邻源码覆盖，新依赖固定为本地提交，尚未推送；未连接实物设备或更新板卡。
