import 'dart:math';

class WaveformCacheService {
  WaveformCacheService._();
  static final WaveformCacheService instance = WaveformCacheService._();

  final Map<String, List<double>> _memoryCache = {};

  /// Retrieves or generates a 64-point normalized waveform peak array (0.0 to 1.0)
  List<double> getWaveformForTrack({
    required String trackId,
    required String title,
    required Duration duration,
    int sampleCount = 64,
  }) {
    if (_memoryCache.containsKey(trackId)) {
      return _memoryCache[trackId]!;
    }

    // Deterministic pseudo-random seed based on trackId and duration
    final seed = (trackId.hashCode ^ duration.inMilliseconds ^ title.hashCode).abs();
    final random = Random(seed);

    final points = <double>[];
    double prev = 0.3 + random.nextDouble() * 0.4;

    for (int i = 0; i < sampleCount; i++) {
      // Harmonic shape envelope (intro fade in, active middle, outro fade)
      final progress = i / sampleCount;
      final envelope = sin(progress * pi); // 0 at ends, 1 in middle

      final variation = (random.nextDouble() - 0.5) * 0.4;
      double val = (prev + variation).clamp(0.1, 0.95);
      val = (val * (0.4 + 0.6 * envelope)).clamp(0.08, 1.0);

      points.add(val);
      prev = val;
    }

    _memoryCache[trackId] = points;
    return points;
  }

  void clearCache() {
    _memoryCache.clear();
  }
}
