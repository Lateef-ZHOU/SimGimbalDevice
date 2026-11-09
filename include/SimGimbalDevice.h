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

#include "GimbalModel.h"  // PanTiltModel
#include "GMBDevice.h"            // 云台族两层
#include "SimGimbalRunSide.h" // 宪法 + 词汇
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
// Qt 元对象末端：Handle、Device 与云台族共用这一个 QObject；析构首句先停收包再拆派生状态。
class SimGimbalDevice final
#ifdef Q_MOC_RUN
    : public SimGimbalHandle // 元对象基类：唯一 QObject 来自 Handle，模板层不加 Q_OBJECT。
#else
    : public GMBDevice<SimGimbalHandle, SimGimbalCollector>
#endif
{
    Q_OBJECT
    Q_PROPERTY(QString displayName MEMBER displayName CONSTANT)
    Q_PROPERTY(QString subtitle MEMBER subtitle CONSTANT)
    Q_PROPERTY(bool isOpen READ isOpen)
    Q_PROPERTY(QVariant holder READ qmlHolder)
    Q_PROPERTY(WorldModel mounting READ mounting NOTIFY mountingChanged)
    Q_PROPERTY(bool slipRing READ hasSlipRing CONSTANT)
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

    explicit SimGimbalDevice(QObject *parent) : GMBDevice(QStringLiteral("转台·仿真"), QStringLiteral("双轴"), parent)
    {
        setObjectName(QStringLiteral("SimGimbal")); // ASCII 标识：落盘会话目录名用
    }
    [[nodiscard]] bool hasSlipRing() const noexcept final { return true; }

    // 预览只查询型号判据，不造 Collector、不发令、不记录操作日志。
    Q_INVOKABLE bool withinTravel(const double pan, const double tilt) const override
    {
        return SimGimbalVocab::withinTravel(pan, tilt);
    }

    // 型号判据（任务预验、造斗与直发共用）：虚拟定位协议只带目标，交出的参数去掉速度；越界返回空并记录原因。
    [[nodiscard]] std::optional<GMBMoveParameters> paramsFor(const PanTiltModel &target, const std::chrono::milliseconds hold,
        const std::optional<GMBMoveParameters::Speeds> &) const override
    {
        if (!SimGimbalVocab::withinTravel(target.pan(), target.tilt()))
        {
            Q_EMIT this->logMessage(QStringLiteral("目标转台角（水平 %1°，俯仰 %2°）超出行程，未下发")
                                        .arg(target.pan(), 0, 'f', 2).arg(target.tilt(), 0, 'f', 2));
            return std::nullopt;
        }
        return GMBMoveParameters{target, hold, std::nullopt};
    }

Q_SIGNALS:
    void lockChanged(HandleCore::ResourcePhase phase) override;
    void mountingChanged(const WorldModel &mounting) override;
    void anglesReady(RxTime at, double pan, double tilt, double azimuth, double elevation) override;

public:
    using GMBDevice::setMounting;
public Q_SLOTS:
    // 连接参数仅携带电机初值；运行中的调速不改 Handle 的连接快照。
    bool open(const double panSpeed, const double tiltSpeed)
    {
        const auto limits = speedLimits(panSpeed, tiltSpeed);
        if (!limits)
            return false;
        if (!SimGimbalHandle::open(SimGimbalParams{.startPan = 0.0, .startTilt = 0.0, .tick = SimGimbalConfig::uplinkInterval, .limits = *limits}))
        {
            Q_EMIT this->logMessage(QStringLiteral("虚拟转台已在运行"));
            return false;
        }
        return true;
    }
    bool setSpeeds(const double panSpeed, const double tiltSpeed)
    {
        const auto limits = speedLimits(panSpeed, tiltSpeed);
        return limits && this->send(SimGimbalVocab::speedOf(*limits), {});
    }
    void close() { SimGimbalHandle::close(); }
    bool issueGoTo(const double pan, const double tilt, const QVariantMap &parameters)
    {
        return GMBDevice::issueGoTo(pan, tilt, parameters);
    }
    bool setMounting(const double azimuth, const double elevation, const double roll)
    {
        return GMBDevice::setMounting(WorldModel(azimuth, elevation, roll), {});
    }
    bool issueStop() override { return this->send(SimGimbalVocab::stopOf(), {}); }

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
            Q_EMIT this->logMessage(QStringLiteral("虚拟转台速度必须是有限数值，未提交"));
            return std::nullopt;
        }
        const auto normalize = [](const double value) {
            constexpr double step = SimGimbalConfig::speedStep;
            return std::round(std::clamp(value, step, SimGimbalConfig::speedMax) / step) * step;
        };
        return MotionLimits{normalize(pan), normalize(tilt)};
    }

    // 按校验后的参数造一只完整的本型号收集器；虚拟定位只带目标，速度由连接/调速单独设置。
    [[nodiscard]] std::shared_ptr<SimGimbalCollector> makeMoveCollector(const GMBMoveParameters &requested) const override
    {
        const auto parameters = paramsFor(requested.target, requested.hold, requested.speeds);
        if (!parameters)
            return nullptr;
        return SimGimbalCollector::create(parameters->target, SimGimbalConfig::angleTol, parameters->hold,
                                          SimGimbalVocab::startOf(parameters->target), SimGimbalVocab::stopOf(),
                                          SimGimbalConfig::expectedDurationMs);
    }
    // [worker] 一张回报 → 实测位形。不是本线协议的字节：不回显、不喂斗。
    [[nodiscard]] std::optional<PanTiltModel> decodeStream(const QByteArray &raw) override
    {
        const auto r = SimGimbalWire::decode<SimGimbalWire::Report>(raw);
        if (!r)
            return std::nullopt;
        return PanTiltModel(r->pan, r->tilt);
    }
    bool issueGoTo(const GMBMoveParameters &parameters) override
    {
        return this->send(SimGimbalVocab::startOf(parameters.target), {}); // 空令牌 = 我不持锁；参数已经 paramsFor 规范化
    }

};
