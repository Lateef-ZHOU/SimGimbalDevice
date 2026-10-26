#pragma once
#include <QtQml/qqmlregistration.h>
#include <algorithm>
#include <cmath>
#include <memory>
#include <optional>
#include <QByteArray>
#include <QString>
#include <QUrl>
#include <QVariantMap>

#include "Algorithm/Geometry/GimbalModel.h"  // PanTiltModel
#include "Device/GMB/GMBDevice.h"            // 云台族两层
#include "Device/GMB/Sim/SimGimbalRunSide.h" // 宪法 + 词汇
#include <SimGimbalHandle.h>   // 连接机制：虚拟电机

// ============================================================
// SimGimbalDevice —— 虚拟云台的官邸：和真云台一样薄
//
// C++ 族层组织采集流水线，本类提供型号判据和配置；QML 族层组织页面。连接 = 给虚拟电机上电
// （起始位形 + 节拍 + 出生限速；没有外部对象，连接分区只有连接 / 断开两个按钮）。**主线上不出生即起**（2026-10-15 用户定：
// 虚拟设备不一定用，默认起会白占资源）；精简分支的自动连接由该分支装配根决定。
// 造斗与前往只打目标位形，解析口把回报译成位形。
// 速度设置由 QML 官邸持有，连接与调速显式交入；本层只校验和成帧。
// 电机在句柄线程保留生效限速，定位与 Collector 仍只带目标，不回读界面设置。
// ============================================================
class SimGimbalDevice final
#ifdef Q_MOC_RUN
    : public GMBDeviceBase // 模板层继承的族级元对象。
#else
    : public GMBDevice<SimGimbalHandle, SimGimbalCollector>
#endif
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(SimGimbalDevice)
    QML_UNCREATABLE("由对应 QML 官邸创建和拥有")
public:
    static SimGimbalDevice *qmlAttachedProperties(QObject *owner) { return new SimGimbalDevice(owner); }
    Q_INVOKABLE QVariantMap controlParameters() const
    {
        return {{"panSpeedDefault", SimGimbalConfig::panSpeedDefault},
                {"tiltSpeedDefault", SimGimbalConfig::tiltSpeedDefault},
                {"speedStep", SimGimbalConfig::speedStep}, {"speedMax", SimGimbalConfig::speedMax}};
    }

    Q_INVOKABLE QVariantMap positioningParameters() const
    {
        return {{"panMin", SimGimbalConfig::panMin}, {"panMax", SimGimbalConfig::panMax},
                 {"tiltMin", SimGimbalConfig::tiltMin}, {"tiltMax", SimGimbalConfig::tiltMax}};
    }

    Q_INVOKABLE [[nodiscard]] QVariantMap chartParameters() const
    {
        return {{"configuration", QVariantMap{
                     {"windowSeconds", std::chrono::duration<double>(SimGimbalConfig::angleChartWindow).count()},
                     {"historySeconds", std::chrono::duration<double>(SimGimbalConfig::angleHistoryWindow).count()},
                     {"intervalSeconds", std::chrono::duration<double>(SimGimbalConfig::uplinkInterval).count()}}}};
    }

    ~SimGimbalDevice() override { PreDestruction(); }

    explicit SimGimbalDevice(QObject *parent) : GMBDevice(QStringLiteral("虚拟云台"), QStringLiteral("仿真 · 匀速电机"), parent)
    {
        setObjectName(QStringLiteral("SimGimbal")); // ASCII 标识：落盘会话目录名用
    }
    [[nodiscard]] bool hasSlipRing() const noexcept final { return true; }

    // 预览只查询型号判据，不造 Collector、不发令、不记录操作日志。
    Q_INVOKABLE bool withinTravel(const double pan, const double tilt) const override
    {
        return SimGimbalVocab::withinTravel(pan, tilt);
    }

public:
    using GMBDevice::setMounting;
public Q_SLOTS:
    // 连接参数仅携带电机初值；运行中的调速不改 Handle 的连接快照。
    bool open(const double panSpeed, const double tiltSpeed)
    {
        const auto limits = speedLimits(panSpeed, tiltSpeed);
        if (!limits)
            return false;
        if (!this->device().open(SimGimbalParams{.startPan = 0.0, .startTilt = 0.0, .tick = SimGimbalConfig::uplinkInterval, .limits = *limits}))
        {
            Q_EMIT this->device().logSource().logMessage(QStringLiteral("虚拟云台已在运行"));
            return false;
        }
        return true;
    }
    bool setSpeeds(const double panSpeed, const double tiltSpeed)
    {
        const auto limits = speedLimits(panSpeed, tiltSpeed);
        return limits && this->device().send(SimGimbalVocab::speedOf(*limits), {});
    }
    void close() { this->device().close(); }
    bool issueGoTo(const double pan, const double tilt, const QVariantMap &parameters)
    {
        return GMBDevice::issueGoTo(pan, tilt, parameters);
    }
    bool setMounting(const double azimuth, const double elevation, const double roll)
    {
        return GMBDeviceBase::setMounting(WorldModel(azimuth, elevation, roll), {});
    }
    bool issueStop() override { return this->device().send(SimGimbalVocab::stopOf(), {}); }

private:
    void PreDestruction() noexcept final
    {
        static_assert(FinalDevice<SimGimbalDevice, decltype(&SimGimbalDevice::PreDestruction)>);
        GMBDevice::PreDestruction();
    }

    // 连接和调速使用同一范围；先钳制再量化，避免有限但极大输入在除以步距时溢出。
    [[nodiscard]] std::optional<MotionLimits> speedLimits(const double pan, const double tilt) const
    {
        if (!std::isfinite(pan) || !std::isfinite(tilt))
        {
            Q_EMIT this->device().logSource().logMessage(QStringLiteral("虚拟云台速度必须是有限数值，未提交"));
            return std::nullopt;
        }
        const auto normalize = [](const double value) {
            constexpr double step = SimGimbalConfig::speedStep;
            return std::round(std::clamp(value, step, SimGimbalConfig::speedMax) / step) * step;
        };
        return MotionLimits{normalize(pan), normalize(tilt)};
    }

    [[nodiscard]] std::shared_ptr<const SimGimbalCollector> makeMoveCollector(
        const PanTiltModel &target, const std::chrono::milliseconds hold, const GMBMoveParameters &) const override
    {
        if (!SimGimbalVocab::withinTravel(target.pan(), target.tilt())) // 与预览和设备页直发同一道检查
            return nullptr;
        return SimGimbalCollector::createPrototype(target, SimGimbalConfig::angleTol, hold, SimGimbalVocab::startOf(target),
                                              SimGimbalVocab::stopOf(), SimGimbalConfig::expectedDurationMs);
    }
    // [worker] 一张回报 → 实测位形。不是本线协议的字节：不回显、不喂斗。
    [[nodiscard]] std::optional<PanTiltModel> decodeStream(const QByteArray &raw) override
    {
        const auto r = SimGimbalWire::decode<SimGimbalWire::Report>(raw);
        if (!r)
            return std::nullopt;
        return PanTiltModel(r->pan, r->tilt);
    }
    bool issueGoTo(const PanTiltModel &target, const GMBMoveParameters &) override
    {
        if (!SimGimbalVocab::withinTravel(target.pan(), target.tilt()))
        {
            Q_EMIT this->device().logSource().logMessage(QStringLiteral("目标云台角（水平 %1°，俯仰 %2°）超出行程，未下发")
                                            .arg(target.pan(), 0, 'f', 2).arg(target.tilt(), 0, 'f', 2));
            return false;
        }
        return this->device().send(SimGimbalVocab::startOf(target), {}); // 空令牌 = 我不持锁
    }

};
