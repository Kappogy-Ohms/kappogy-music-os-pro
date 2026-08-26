import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/core/utils/audio_math.dart';
import 'package:kappogy_music_os_pro/core/utils/duration_formatter.dart';

void main() {
  group('AudioMath Tests', () {
    test('linearToDb converts correctly', () {
      expect(AudioMath.linearToDb(1.0), closeTo(0.0, 0.01));
      expect(AudioMath.linearToDb(0.0), closeTo(-60.0, 0.01));
    });

    test('dbToLinear converts correctly', () {
      expect(AudioMath.dbToLinear(0.0), closeTo(1.0, 0.01));
      expect(AudioMath.dbToLinear(-20.0), closeTo(0.1, 0.01));
    });

    test('calculateCrossfader center balance', () {
      final (gainA, gainB) = AudioMath.calculateCrossfader(0.0, curve: 'equal_power');
      expect(gainA, closeTo(0.707, 0.01));
      expect(gainB, closeTo(0.707, 0.01));
    });

    test('generateSimulatedWaveform generates points in valid range', () {
      final waveform = AudioMath.generateSimulatedWaveform('test_track', points: 32);
      expect(waveform.length, 32);
      for (final p in waveform) {
        expect(p, greaterThanOrEqualTo(0.15));
        expect(p, lessThanOrEqualTo(1.0));
      }
    });

    test('formatCamelotKey maps harmonic keys', () {
      expect(AudioMath.formatCamelotKey('Am'), '8A');
      expect(AudioMath.formatCamelotKey('C'), '8B');
    });
  });

  group('DurationFormatter Tests', () {
    test('formats seconds and durations correctly', () {
      expect(DurationFormatter.format(const Duration(minutes: 3, seconds: 45)), '3:45');
      expect(DurationFormatter.format(const Duration(hours: 1, minutes: 2, seconds: 5)), '1:02:05');
      expect(DurationFormatter.format(null), '0:00');
    });

    test('formats file sizes', () {
      expect(DurationFormatter.formatFileSize(1024), '1.0 KB');
      expect(DurationFormatter.formatFileSize(1048576 * 5), '5.0 MB');
    });
  });
}
