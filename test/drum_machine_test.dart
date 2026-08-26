import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/recorder/domain/drum_machine_model.dart';
import 'package:kappogy_music_os_pro/features/recorder/presentation/drum_machine_providers.dart';
import 'package:kappogy_music_os_pro/features/recorder/presentation/drum_machine_sheet.dart';

void main() {
  group('DrumMachine Tests', () {
    test('DrumMachineNotifier toggles steps, sets bpm, swing, and kit', () {
      final notifier = DrumMachineNotifier();
      addTearDown(notifier.dispose);

      expect(notifier.state.isPlaying, isFalse);
      expect(notifier.state.bpm, equals(120.0));

      notifier.setBpm(135.0);
      expect(notifier.state.bpm, equals(135.0));

      notifier.setSwing(25.0);
      expect(notifier.state.swing, equals(25.0));

      notifier.setKit(DrumKitType.dance909);
      expect(notifier.state.kit, equals(DrumKitType.dance909));

      // Toggle step
      final initialKick = notifier.state.activePattern.steps[DrumSound.kick]![1];
      notifier.toggleStep(DrumSound.kick, 1);
      expect(notifier.state.activePattern.steps[DrumSound.kick]![1], equals(!initialKick));

      notifier.toggleMute(DrumSound.snare);
      expect(notifier.state.mutedSounds.contains(DrumSound.snare), isTrue);

      notifier.toggleSolo(DrumSound.kick);
      expect(notifier.state.soloSound, equals(DrumSound.kick));

      notifier.clearPattern();
      for (final sound in DrumSound.values) {
        expect(notifier.state.activePattern.steps[sound]!.every((s) => !s), isTrue);
      }
    });

    testWidgets('DrumMachineSheet renders sequencer pads and transport buttons', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DrumMachineSheet(),
            ),
          ),
        ),
      );

      expect(find.text('STUDIO 16-STEP BEAT SEQUENCER'), findsOneWidget);
      expect(find.text('TAP TEMPO'), findsOneWidget);
      expect(find.text('BOUNCE BEAT TO LIBRARY'), findsOneWidget);
      expect(find.text('CLEAR'), findsOneWidget);
    });
  });
}
