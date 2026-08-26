import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/pitch_formant_lab_sheet.dart';

void main() {
  group('PitchFormantLab Tests', () {
    test('PitchFormantLabNotifier clamps pitch and applies presets', () {
      final notifier = PitchFormantLabNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.pitchSemitones, equals(0.0));
      expect(notifier.state.speedMultiplier, equals(1.0));

      notifier.setPitch(6.0);
      expect(notifier.state.pitchSemitones, equals(6.0));

      notifier.setSpeed(1.5);
      expect(notifier.state.speedMultiplier, equals(1.5));

      notifier.setFormant(-3.0);
      expect(notifier.state.formantShift, equals(-3.0));

      notifier.applyPreset(PitchPresetMode.nightcore);
      expect(notifier.state.pitchSemitones, equals(4.0));
      expect(notifier.state.speedMultiplier, equals(1.25));

      notifier.reset();
      expect(notifier.state.pitchSemitones, equals(0.0));
      expect(notifier.state.speedMultiplier, equals(1.0));
    });

    testWidgets('PitchFormantLabSheet renders potentiometers and rocker', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PitchFormantLabSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PITCH & FORMANT SHIFTING LAB'), findsOneWidget);
      expect(find.text('DSP LAB PRESETS'), findsOneWidget);
      expect(find.text('PITCH'), findsOneWidget);
      expect(find.text('TEMPO'), findsOneWidget);
      expect(find.text('FORMANT'), findsOneWidget);
      expect(find.text('VOCAL TIMBRE FORMANT PRESERVATION'), findsOneWidget);
    });
  });
}
