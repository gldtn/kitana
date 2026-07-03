#pragma once

#include <array>
#include <cstdint>
#include <mutex>
#include <stop_token>
#include <thread>

namespace kitana::cava {

constexpr std::uint32_t audioSampleRate = 44100;
constexpr std::uint32_t audioChunkSize = 512;

class AudioCollector {
public:
  AudioCollector(const AudioCollector&) = delete;
  AudioCollector& operator=(const AudioCollector&) = delete;

  static AudioCollector& instance();

  void ref();
  void unref();

  void clear();
  void loadSamples(const float* samples, std::uint32_t count);
  std::uint32_t readSamples(double* output, std::uint32_t count = audioChunkSize);

private:
  AudioCollector();
  ~AudioCollector();

  std::mutex m_lifecycleMutex;
  std::mutex m_bufferMutex;
  std::array<float, audioChunkSize> m_buffer;
  std::jthread m_thread;
  int m_refCount = 0;

  void startLocked();
  void stopLocked();
  void run(std::stop_token token);
};

} // namespace kitana::cava
