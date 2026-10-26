#pragma once
#include "Device/GMB/GMBCollector.h"
#include <chrono>
#include <QByteArray>
#include <QList>

#include "Algorithm/Geometry/GimbalModel.h" // PanTiltModel（目标位形）
#include <SimGimbalProtocol.h>  // 库内命令/回报与两轴限速

// ============================================================
// 虚拟云台的宪法常量店 + 运行侧词汇（意图 → 指令）
//
// 行程：水平整圈带滑环（照铭辰，好让任务计划在真机与虚拟机之间原样互换），俯仰 0°～90°——不照抄铭辰的 −2°～92°
// （2026-10-15 用户定：那是真机伺服的余量，虚拟云台写出来给人看会诧异）；速度与判到位容差是
// 本型号自己的常量，与真机互不抄数（驻留由任务页交，斗里有下限）。指令就是 SimGimbalWire 的 POD，形制照 Pelco-D：
// 定位命令只带目标位形，限速另有速度命令（滑块改了即下发），停机命令把目标置空。
// ============================================================
namespace SimGimbalConfig
{
inline constexpr double panMin = 0.0;
inline constexpr double panMax = 360.0;
inline constexpr double tiltMin = 0.0;
inline constexpr double tiltMax = 90.0;
inline constexpr double panSpeedDefault = 30.0;  // °/s
inline constexpr double tiltSpeedDefault = 20.0; // °/s
inline constexpr double speedMax = 120.0;
inline constexpr double speedStep = 0.1;
inline constexpr double angleTol = 0.05;
inline constexpr int expectedDurationMs = 60000;
inline constexpr auto uplinkInterval = std::chrono::milliseconds{20};
inline constexpr auto angleChartWindow = std::chrono::minutes{2};
inline constexpr auto angleHistoryWindow = std::chrono::hours{1}; // 覆盖虚拟卡最长累积窗，显示窗不变。
} // namespace SimGimbalConfig

namespace SimGimbalVocab
{
// 直接检查角度值，不在查询过程中折返或钳值；预览、造斗与手动发令共用。
[[nodiscard]] inline bool withinTravel(const double pan, const double tilt)
{
    return pan >= SimGimbalConfig::panMin && pan <= SimGimbalConfig::panMax &&
           tilt >= SimGimbalConfig::tiltMin && tilt <= SimGimbalConfig::tiltMax;
}
[[nodiscard]] inline QList<QByteArray> startOf(const PanTiltModel &target)
{
    return {SimGimbalWire::encode(SimGimbalWire::Command{SimGimbalWire::Command::GoTo, target.pan(), target.tilt(), {}})};
}
[[nodiscard]] inline QList<QByteArray> stopOf()
{
    return {SimGimbalWire::encode(SimGimbalWire::Command{SimGimbalWire::Command::Stop, 0.0, 0.0, {}})};
}
[[nodiscard]] inline QList<QByteArray> speedOf(const MotionLimits &limits)
{
    return {SimGimbalWire::encode(SimGimbalWire::Command{SimGimbalWire::Command::SetSpeed, 0.0, 0.0, limits})};
}
} // namespace SimGimbalVocab

struct SimGimbalCollectorTag;
using SimGimbalCollector = TypedGMBCollector<SimGimbalCollectorTag>;
