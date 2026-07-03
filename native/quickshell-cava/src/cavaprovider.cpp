#include "cavaprovider.hpp"

#if __has_include(<cava/cavacore.h>)
#include <cava/cavacore.h>
#elif __has_include(<cavacore.h>)
#include <cavacore.h>
#else
#error "cavacore.h not found"
#endif

#include <algorithm>
#include <cmath>
#include <qloggingcategory.h>

Q_LOGGING_CATEGORY(lcKitanaCava, "kitana.cava", QtInfoMsg)

namespace kitana::cava {

namespace {

constexpr double noiseReduction = 0.77;
constexpr int lowCutoffFrequency = 50;
constexpr int highCutoffFrequency = 10000;

double boundedSpectrumValue(double value) {
  if (!std::isfinite(value)) {
    return 0.0;
  }

  return std::clamp(value, 0.0, 1.0);
}

} // namespace

CavaProvider::CavaProvider(QObject* parent)
    : QObject(parent) {
  m_timer.setTimerType(Qt::PreciseTimer);
  updateTimerInterval();
  connect(&m_timer, &QTimer::timeout, this, &CavaProvider::processFrame);
}

CavaProvider::~CavaProvider() {
  m_timer.stop();

  if (m_active) {
    AudioCollector::instance().unref();
  }

  cleanupPlan();
}

int CavaProvider::bars() const {
  return m_bars;
}

void CavaProvider::setBars(int bars) {
  bars = std::max(0, bars);

  if (m_bars == bars) {
    return;
  }

  m_bars = bars;
  m_output.assign(static_cast<std::size_t>(m_bars), 0.0);
  m_filteredValues.assign(static_cast<std::size_t>(m_bars), 0.0);
  resetValues();
  reloadPlan();

  emit barsChanged();
}

bool CavaProvider::active() const {
  return m_active;
}

void CavaProvider::setActive(bool active) {
  if (m_active == active) {
    return;
  }

  m_active = active;

  if (m_active) {
    AudioCollector::instance().ref();
    reloadPlan();
    if (m_bars > 0) {
      m_timer.start();
    }
  } else {
    m_timer.stop();
    AudioCollector::instance().unref();
    cleanupPlan();
    resetValues();
  }

  emit activeChanged();
}

int CavaProvider::frameRate() const {
  return m_frameRate;
}

void CavaProvider::setFrameRate(int frameRate) {
  frameRate = std::clamp(frameRate, 1, 120);

  if (m_frameRate == frameRate) {
    return;
  }

  m_frameRate = frameRate;
  updateTimerInterval();
  emit frameRateChanged();
}

QVariantList CavaProvider::values() const {
  return m_values;
}

void CavaProvider::processFrame() {
  if (!m_plan || m_bars <= 0 || m_output.empty()) {
    return;
  }

  const int count = static_cast<int>(AudioCollector::instance().readSamples(m_input.data()));
  if (count <= 0) {
    return;
  }

  cava_execute(m_input.data(), count, m_output.data(), m_plan);

  std::vector<double> values(static_cast<std::size_t>(m_bars), 0.0);
  double carry = 0.0;
  constexpr double spreadDecay = 1.0 / 1.5;

  for (int i = 0; i < m_bars; ++i) {
    carry = std::max(boundedSpectrumValue(m_output[static_cast<std::size_t>(i)]), carry * spreadDecay);
    values[static_cast<std::size_t>(i)] = carry;
  }

  carry = 0.0;
  for (int i = m_bars - 1; i >= 0; --i) {
    carry = std::max(boundedSpectrumValue(m_output[static_cast<std::size_t>(i)]), carry * spreadDecay);
    values[static_cast<std::size_t>(i)] = std::max(values[static_cast<std::size_t>(i)], carry);
  }

  publishValues(values);
}

void CavaProvider::reloadPlan() {
  cleanupPlan();

  if (!m_active || m_bars <= 0) {
    return;
  }

  m_plan = cava_init(m_bars, audioSampleRate, 1, 1, noiseReduction, lowCutoffFrequency, highCutoffFrequency);
  if (!m_plan) {
    qCWarning(lcKitanaCava) << "failed to initialize cavacore";
    return;
  }
}

void CavaProvider::cleanupPlan() {
  if (!m_plan) {
    return;
  }

  cava_destroy(m_plan);
  m_plan = nullptr;
}

void CavaProvider::resetValues() {
  std::vector<double> values(static_cast<std::size_t>(m_bars), 0.0);
  m_filteredValues.clear();
  publishValues(values);
}

void CavaProvider::publishValues(const std::vector<double>& values) {
  if (values == m_filteredValues) {
    return;
  }

  m_filteredValues = values;
  m_values.clear();
  m_values.reserve(static_cast<qsizetype>(values.size()));

  for (double value : values) {
    m_values.append(boundedSpectrumValue(value));
  }

  emit valuesChanged();
}

void CavaProvider::updateTimerInterval() {
  m_timer.setInterval(std::max(1, 1000 / m_frameRate));
}

} // namespace kitana::cava
