import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/data/waveform_cache_service.dart';

void main() {
  group('WaveformCacheService Tests', () {
    test('generates normalized 64-sample waveform peaks and caches result', () {
      final service = WaveformCacheService.instance;
      service.clearCache();

      final points1 = service.getWaveformForTrack(
        trackId: 'track_123',
        title: 'Midnight Lagos',
        duration: const Duration(seconds: 214),
      );

      expect(points1.length, 64);
      for (final p in points1) {
        expect(p >= 0.0 && p <= 1.0, true);
      }

      // Verify cached retrieval returns identical instance
      final points2 = service.getWaveformForTrack(
        trackId: 'track_123',
        title: 'Midnight Lagos',
        duration: const Duration(seconds: 214),
      );

      expect(identical(points1, points2), true);
    });
  });
}
