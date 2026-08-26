import 'dart:math';

/// Audio mathematics for decibel scaling, crossfading curves, and harmonic keys.
class AudioMath {
  /// Converts linear gain (0.0 to 1.0) to decibels (-infinity to 0 dB)
  static double linearToDb(double linear) {
    if (linear <= 0.00001) return -60.0;
    return 20.0 * (log(linear) / ln10);
  }

  /// Converts decibels (-60 dB to +15 dB) to linear gain (0.0 to 5.6)
  static double dbToLinear(double db) {
    return pow(10.0, db / 20.0).toDouble();
  }

  /// Calculates Deck A and Deck B volume gains based on crossfader position (-1.0 to 1.0)
  /// and curve type ('equal_power', 'linear', or 'cut')
  static (double deckA, double deckB) calculateCrossfader(
    double position, {
    String curve = 'equal_power',
  }) {
    // Clamped between -1.0 (all Deck A) and 1.0 (all Deck B)
    final double clamped = position.clamp(-1.0, 1.0);
    final double normalized = (clamped + 1.0) / 2.0; // 0.0 to 1.0

    if (curve == 'cut') {
      // Scratch DJ sharp cut
      final double a = normalized < 0.95 ? 1.0 : (1.0 - normalized) * 20.0;
      final double b = normalized > 0.05 ? 1.0 : normalized * 20.0;
      return (a.clamp(0.0, 1.0), b.clamp(0.0, 1.0));
    } else if (curve == 'linear') {
      return (1.0 - normalized, normalized);
    } else {
      // Equal power (constant loudness across center)
      final double a = cos(normalized * pi / 2);
      final double b = sin(normalized * pi / 2);
      return (a, b);
    }
  }

  /// Generates a pseudo-deterministic waveform envelope for visualization from audio metadata
  static List<double> generateSimulatedWaveform(String seed, {int points = 80}) {
    final int hash = seed.hashCode.abs();
    final Random rnd = Random(hash);
    final List<double> waveform = [];
    double current = 0.3 + (rnd.nextDouble() * 0.4);

    for (int i = 0; i < points; i++) {
      // Create organic peaks and valleys
      final double delta = (rnd.nextDouble() - 0.5) * 0.35;
      current = (current + delta).clamp(0.15, 0.98);
      // Add beat pulse every 8 points
      if (i % 8 == 0) {
        current = (current + 0.3).clamp(0.2, 1.0);
      }
      waveform.add(current);
    }
    return waveform;
  }

  /// Estimates musical key and Camelot wheel code
  static String formatCamelotKey(String key) {
    const Map<String, String> camelotMap = {
      'C': '8B', 'Am': '8A',
      'G': '9B', 'Em': '9A',
      'D': '10B', 'Bm': '10A',
      'A': '11B', 'F#m': '11A',
      'E': '12B', 'C#m': '12A',
      'B': '1B', 'G#m': '1A',
      'F#': '2B', 'D#m': '2A',
      'Db': '3B', 'Bbm': '3A',
      'Ab': '4B', 'Fm': '4A',
      'Eb': '5B', 'Cm': '5A',
      'Bb': '6B', 'Gm': '6A',
      'F': '7B', 'Dm': '7A',
    };
    return camelotMap[key] ?? key;
  }
}
