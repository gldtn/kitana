#include "audiocollector.hpp"

#include <algorithm>
#include <pipewire/pipewire.h>
#include <qloggingcategory.h>
#include <spa/param/audio/format-utils.h>
#include <spa/param/latency-utils.h>
#include <spa/utils/names.h>

Q_LOGGING_CATEGORY(lcKitanaCavaAudio, "kitana.cava.audio", QtInfoMsg)

namespace kitana::cava {

namespace {

struct PipeWireContext {
  AudioCollector* collector = nullptr;
  std::stop_token token;
  pw_main_loop* loop = nullptr;
  pw_stream* stream = nullptr;
  spa_source* timer = nullptr;
  bool streaming = false;
};

void clearWhenIdle(void* data, std::uint64_t) {
  auto* context = static_cast<PipeWireContext*>(data);

  if (context->token.stop_requested()) {
    pw_main_loop_quit(context->loop);
    return;
  }

  if (!context->streaming) {
    context->collector->clear();
  }
}

void updateStreamState(void* data, pw_stream_state, pw_stream_state state, const char*) {
  auto* context = static_cast<PipeWireContext*>(data);
  context->streaming = state == PW_STREAM_STATE_STREAMING;

  if (state == PW_STREAM_STATE_PAUSED) {
    context->collector->clear();
  } else if (state == PW_STREAM_STATE_ERROR) {
    pw_main_loop_quit(context->loop);
  }
}

void processStream(void* data) {
  auto* context = static_cast<PipeWireContext*>(data);

  if (context->token.stop_requested()) {
    pw_main_loop_quit(context->loop);
    return;
  }

  pw_buffer* pipewireBuffer = pw_stream_dequeue_buffer(context->stream);
  if (!pipewireBuffer) {
    return;
  }

  spa_buffer* buffer = pipewireBuffer->buffer;
  spa_data& audioData = buffer->datas[0];
  const auto* samples = static_cast<const float*>(audioData.data);

  if (samples && audioData.chunk && audioData.chunk->size > 0) {
    context->collector->loadSamples(samples, audioData.chunk->size / sizeof(float));
  }

  pw_stream_queue_buffer(context->stream, pipewireBuffer);
}

std::uint32_t nextPowerOfTwo(std::uint32_t value) {
  if (value == 0) {
    return 1;
  }

  --value;
  value |= value >> 1;
  value |= value >> 2;
  value |= value >> 4;
  value |= value >> 8;
  value |= value >> 16;
  return value + 1;
}

} // namespace

AudioCollector& AudioCollector::instance() {
  static AudioCollector collector;
  return collector;
}

AudioCollector::AudioCollector() {
  clear();
}

AudioCollector::~AudioCollector() {
  std::lock_guard lock(m_lifecycleMutex);
  stopLocked();
}

void AudioCollector::ref() {
  std::lock_guard lock(m_lifecycleMutex);
  ++m_refCount;

  if (m_refCount == 1) {
    startLocked();
  }
}

void AudioCollector::unref() {
  std::lock_guard lock(m_lifecycleMutex);

  if (m_refCount <= 0) {
    return;
  }

  --m_refCount;
  if (m_refCount == 0) {
    stopLocked();
  }
}

void AudioCollector::clear() {
  std::lock_guard lock(m_bufferMutex);
  m_buffer.fill(0.0F);
}

void AudioCollector::loadSamples(const float* samples, std::uint32_t count) {
  if (!samples) {
    clear();
    return;
  }

  count = std::min<std::uint32_t>(count, audioChunkSize);

  std::lock_guard lock(m_bufferMutex);
  m_buffer.fill(0.0F);
  std::transform(samples, samples + count, m_buffer.begin(), [](float sample) {
    return std::clamp(sample, -1.0F, 1.0F);
  });
}

std::uint32_t AudioCollector::readSamples(double* output, std::uint32_t count) {
  if (!output) {
    return 0;
  }

  count = std::min<std::uint32_t>(count == 0 ? audioChunkSize : count, audioChunkSize);

  std::lock_guard lock(m_bufferMutex);
  std::transform(m_buffer.begin(), m_buffer.begin() + count, output, [](float sample) {
    return static_cast<double>(sample);
  });

  return count;
}

void AudioCollector::startLocked() {
  if (m_thread.joinable()) {
    return;
  }

  clear();
  m_thread = std::jthread([this](std::stop_token token) {
    run(token);
  });
}

void AudioCollector::stopLocked() {
  if (!m_thread.joinable()) {
    clear();
    return;
  }

  m_thread.request_stop();
  m_thread.join();
  clear();
}

void AudioCollector::run(std::stop_token token) {
  pw_init(nullptr, nullptr);

  PipeWireContext context;
  context.collector = this;
  context.token = token;
  context.loop = pw_main_loop_new(nullptr);

  if (!context.loop) {
    qCWarning(lcKitanaCavaAudio) << "failed to create PipeWire main loop";
    pw_deinit();
    return;
  }

  timespec idleInterval = {0, 250 * SPA_NSEC_PER_MSEC};
  context.timer = pw_loop_add_timer(pw_main_loop_get_loop(context.loop), clearWhenIdle, &context);
  if (!context.timer) {
    qCWarning(lcKitanaCavaAudio) << "failed to create PipeWire idle timer";
    pw_main_loop_destroy(context.loop);
    pw_deinit();
    return;
  }
  pw_loop_update_timer(pw_main_loop_get_loop(context.loop), context.timer, &idleInterval, &idleInterval, false);

  pw_properties* properties = pw_properties_new(
      PW_KEY_MEDIA_TYPE, "Audio", PW_KEY_MEDIA_CATEGORY, "Capture", PW_KEY_MEDIA_ROLE, "Music", nullptr);
  pw_properties_set(properties, PW_KEY_STREAM_CAPTURE_SINK, "true");
  pw_properties_setf(properties, PW_KEY_NODE_LATENCY, "%u/%u", nextPowerOfTwo(512 * audioSampleRate / 48000), audioSampleRate);
  pw_properties_set(properties, PW_KEY_NODE_PASSIVE, "true");
  pw_properties_set(properties, PW_KEY_NODE_VIRTUAL, "true");
  pw_properties_set(properties, PW_KEY_STREAM_DONT_REMIX, "false");
  pw_properties_set(properties, "channelmix.upmix", "true");

  std::array<std::uint8_t, 1024> podBuffer = {};
  spa_pod_builder builder;
  spa_pod_builder_init(&builder, podBuffer.data(), podBuffer.size());

  spa_audio_info_raw audioInfo = {};
  audioInfo.format = SPA_AUDIO_FORMAT_F32;
  audioInfo.rate = audioSampleRate;
  audioInfo.channels = 1;

  const spa_pod* params[1] = {spa_format_audio_raw_build(&builder, SPA_PARAM_EnumFormat, &audioInfo)};

  pw_stream_events events = {};
  events.version = PW_VERSION_STREAM_EVENTS;
  events.state_changed = updateStreamState;
  events.process = processStream;

  context.stream = pw_stream_new_simple(pw_main_loop_get_loop(context.loop), "kitana-cava", properties, &events, &context);
  if (!context.stream) {
    qCWarning(lcKitanaCavaAudio) << "failed to create PipeWire stream";
    pw_main_loop_destroy(context.loop);
    pw_deinit();
    return;
  }

  const int connected = pw_stream_connect(context.stream, PW_DIRECTION_INPUT, PW_ID_ANY,
      static_cast<pw_stream_flags>(PW_STREAM_FLAG_AUTOCONNECT | PW_STREAM_FLAG_MAP_BUFFERS), params, 1);
  if (connected < 0) {
    qCWarning(lcKitanaCavaAudio) << "failed to connect PipeWire stream";
    pw_stream_destroy(context.stream);
    pw_main_loop_destroy(context.loop);
    pw_deinit();
    return;
  }

  pw_main_loop_run(context.loop);

  pw_stream_destroy(context.stream);
  pw_main_loop_destroy(context.loop);
  pw_deinit();
}

} // namespace kitana::cava
