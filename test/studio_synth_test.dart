import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/studio_synth_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudioSynth Tests', () {
    test('StudioSynthNotifier updates frequency and locks A440', () {
      final notifier = StudioSynthNotifier();

      expect(notifier.state.frequencyHz, equals(440.0));
      expect(notifier.state.waveform, equals(OscillatorWaveform.sine));

      notifier.setFrequency(880.0);
      expect(notifier.state.frequencyHz, equals(880.0));

      notifier.setWaveform(OscillatorWaveform.sawtooth);
      expect(notifier.state.waveform, equals(OscillatorWaveform.sawtooth));

      notifier.lockA440();
      expect(notifier.state.frequencyHz, equals(440.0));
      expect(notifier.state.waveform, equals(OscillatorWaveform.sine));

      notifier.setFilter(3200.0);
      expect(notifier.state.filterCutoffHz, equals(3200.0));

      notifier.playNote(2, 329.63);
      expect(notifier.state.activeNoteIndex, equals(2));
      expect(notifier.state.frequencyHz, equals(329.63));
      expect(notifier.state.isOscillatorActive, isTrue);

      notifier.releaseNote();
      expect(notifier.state.activeNoteIndex, equals(-1));
    });

    testWidgets('StudioSynthSheet renders frequency card and playable keybed', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StudioSynthSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('STUDIO TONE GENERATOR & TUNER SYNTH'), findsOneWidget);
      expect(find.text('OSCILLATOR FREQUENCY'), findsOneWidget);
      expect(find.text('LOCK A440'), findsOneWidget);
      expect(find.text('PLAYABLE MUSICIAN TOUCH KEYBED'), findsOneWidget);
      expect(find.text('FREQ SWEEP'), findsOneWidget);
      expect(find.text('LP FILTER'), findsOneWidget);
    });
  });
}
