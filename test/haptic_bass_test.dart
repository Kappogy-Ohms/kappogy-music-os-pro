import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/haptic_bass_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticBass Tests', () {
    test('HapticBassNotifier updates rhythm pattern and cutoff', () {
      final notifier = HapticBassNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.pattern, equals(HapticBeatPattern.transientDynamic));

      notifier.setPattern(HapticBeatPattern.quarterBeat);
      expect(notifier.state.pattern, equals(HapticBeatPattern.quarterBeat));

      notifier.setIntensity(90.0);
      expect(notifier.state.intensityPercent, equals(90.0));

      notifier.setCutoff(60.0);
      expect(notifier.state.cutoffFrequencyHz, equals(60.0));

      notifier.toggleAudible();
      expect(notifier.state.isMetronomeAudible, isTrue);

      notifier.triggerHapticPulse(); // Safe mock test
    });

    testWidgets('HapticBassSheet renders vibration controls and test pulse button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HapticBassSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TACTILE HAPTIC SUB-BASS & BEAT SHAKER'), findsOneWidget);
      expect(find.text('RHYTHMIC HAPTIC BEAT PATTERN'), findsOneWidget);
      expect(find.text('INTENSITY'), findsOneWidget);
      expect(find.text('SUB CUTOFF'), findsOneWidget);
    });
  });
}
