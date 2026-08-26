import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/dj_mode/presentation/stem_mixer_sheet.dart';

void main() {
  group('StemMixer Tests', () {
    test('StemMixerNotifier updates volume, mutes and solos correctly', () {
      final notifier = StemMixerNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.vocals.volume, equals(0.85));

      notifier.setVolume('VOCALS', 0.5);
      expect(notifier.state.vocals.volume, equals(0.5));

      notifier.toggleMute('DRUMS');
      expect(notifier.state.drums.isMuted, isTrue);

      notifier.toggleSolo('BASS');
      expect(notifier.state.bass.isSolo, isTrue);

      notifier.resetAll();
      expect(notifier.state.drums.isMuted, isFalse);
      expect(notifier.state.bass.isSolo, isFalse);
    });

    testWidgets('StemMixerSheet renders 4 stem channels and controls', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StemMixerSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('4-TRACK MULTI-STEM STUDIO MIXER'), findsOneWidget);
      expect(find.text('VOCALS'), findsOneWidget);
      expect(find.text('DRUMS'), findsOneWidget);
      expect(find.text('BASS'), findsOneWidget);
      expect(find.text('MELODY'), findsOneWidget);
    });
  });
}
