#pragma once

#include "audiocollector.hpp"

#include <QTimer>
#include <QVariantList>
#include <array>
#include <qqmlintegration.h>
#include <vector>

struct cava_plan;

namespace kitana::cava {

class CavaProvider : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(int bars READ bars WRITE setBars NOTIFY barsChanged)
  Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
  Q_PROPERTY(int frameRate READ frameRate WRITE setFrameRate NOTIFY frameRateChanged)
  Q_PROPERTY(QVariantList values READ values NOTIFY valuesChanged)

public:
  explicit CavaProvider(QObject* parent = nullptr);
  ~CavaProvider() override;

  [[nodiscard]] int bars() const;
  void setBars(int bars);

  [[nodiscard]] bool active() const;
  void setActive(bool active);

  [[nodiscard]] int frameRate() const;
  void setFrameRate(int frameRate);

  [[nodiscard]] QVariantList values() const;

signals:
  void barsChanged();
  void activeChanged();
  void frameRateChanged();
  void valuesChanged();

private:
  QTimer m_timer;
  std::array<double, audioChunkSize> m_input = {};
  std::vector<double> m_output;
  std::vector<double> m_filteredValues;
  QVariantList m_values;
  cava_plan* m_plan = nullptr;
  int m_bars = 0;
  int m_frameRate = 30;
  bool m_active = false;

  void processFrame();
  void reloadPlan();
  void cleanupPlan();
  void resetValues();
  void publishValues(const std::vector<double>& values);
  void updateTimerInterval();
};

} // namespace kitana::cava
