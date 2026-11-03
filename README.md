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

## 官邸自有的仿真 Handle（2026-11-03）

Handle、内部协议和两轴运动模型及其测试由 HandleCore 原样迁回；头文件名与目标名保持，运行、重连、取消及关闭逻辑不变。`handle/` 可独立构建，仅需 Qt Core >= 6.8.3、C++20 与 HandleCore，不依赖 QML。完整官邸仍需上面的 Qt Quick 依赖。

```sh
cmake -S handle -B build-handle -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="<Qt前缀>"
cmake --build build-handle --config Release --parallel 4
ctest --test-dir build-handle -C Release --output-on-failure
```

本仓库提供 `Lidar::SimGimbal`；完整官邸构建自动包含该目标及 `tests/handle`。HandleCore 不再提供仿真模块开关。仿真协议仍只用于进程内部，不作为网络协议。

- `SimGimbalParams` 接收有限初始角度、有限且非负的两轴限速，以及 1..INT_MAX 毫秒的回报周期。`start` 保留基类的异步接受语义，连接线程打开时检查参数，非法值记录原因并按首次连接失败路径退出；不改 HandleBase 的裁决、重连或关闭机制。
- `SimGimbalWire::Command` 提供 GoTo / Stop / SetSpeed。send 同步检查大小、指令类型与本指令使用的字段；拒绝非有限目标、负数或非有限速度，返回 false 且不排队。无关字段不参与校验。成功表示已排队，不表示电机已到达。协议编解码模板只接受 Command / Report。
- `GimbalMotion::Pose` 是两轴角度值，不含应用的 PanTiltModel 或世界坐标知识。模型归一化为 pan [0,360)、tilt [-180,180)，沿最短圆周路径运动；正负半圈均选正向。两轴按各自限速与真实流逝时间推进、到位不过冲，零限速保持该轴位置，Stop 清空目标，调速不重置位置。模型直接使用者若传入非有限角度、非法限速或负数/非有限时间步，则抛出 std::invalid_argument，不修改已有状态。
- 型号行程、速度上限/步距、UI 初值及安装坐标转换归应用。限速初值不参与连接参数相等比较，运行调速不触发重连。连接对象、QTimer、运动状态均只在工作线程访问；命令和退出经原有队列提交，回报仍同步进入数据回调，RxTime 仍为 system_clock 值。具体析构首先同步 stop，等待回调退出。
- 线格式保留本机 POD 原样复制（含本机布局、对齐、字节序），只供同一进程的调用方与 Handle 使用。两端分别编译可用不等于跨平台网络序列化，不直接把此报文用作 Windows/Linux 间的 UDP 协议。
- 风场/谱生成、QML 历史读取、Collector、设备业务仍由各自官邸维护；虚拟采集执行机制归 SimCardDevice，不增加通用仿真基类。

本轮验证：Windows/MSVC/Qt 6.11.2 完整官邸 Release 与独立头编译通过，页面及 Handle CTest 3/3；Qt Core 独立入口 2/2。Linux/GCC 16.2.1/Qt Core 6.8.3 独立入口 2/2，未测 Linux QML 页面或 ARM。主程序两官邸 qmllint 通过，保留既有 QObject 属性静态分析提示。证据 build-migration、build-handle 及 Linux ~/.cache/lidar-sim-handle-move-20261103。固定本地 HandleCore 与 TaskCore 提交，联调使用源码覆盖；未推送。

## 源码目录（2026-11-03）

公开文件直接放在 `include/`，引用时使用文件名，不再携带原单仓库的业务目录前缀。CMake 目标名称、C++ 类型和 QML 模块名保持不变；使用方须同步更新头文件路径及固定依赖版本。

目录整理验证（2026-11-03）：Windows：公开头独立编译、页面和 Handle 测试 3/3 通过；Linux Qt Core 6.8.3：独立 Handle 构建、CTest 2/2 通过。本轮通过本地源码覆盖验证，固定依赖同步更新到本地提交；尚未推送，不代表已验证远端拉取。
