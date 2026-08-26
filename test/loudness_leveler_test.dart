import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/loudness_leveler_sheet.dart';

void main() {
  group('LoudnessLeveler Tests', () {
    test('LoudnessLevelerNotifier toggles state and updates target standard', () {
      final notifier = LoudnessLevelerNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.standard, equals(LoudnessStandard.streaming14));
      expect(notifier.state.standard.targetLufs, equals(-14.0));

      notifier.setStandard(LoudnessStandard.audiophileEbu18);
      expect(notifier.state.standard, equals(LoudnessStandard.audiophileEbu18));
      expect(notifier.state.standard.targetLufs, equals(-18.0));

      notifier.setManualTrim(4.5);
      expect(notifier.state.manualTrimDb, equals(4.5));

      notifier.toggleTruePeakGuard();
      expect(notifier.state.isTruePeakGuardEnabled, isFalse);

      notifier.toggleEnabled();
      expect(notifier.state.isEnabled, isFalse);
    });

    testWidgets('LoudnessLevelerSheet renders target standards and controls', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoudnessLevelerSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('EBU R128 / REPLAYGAIN LUFS LOUDNESS LEVELER'), findsOneWidget);
      expect(find.text('TARGET LOUDNESS STANDARD'), findsOneWidget);
      expect(find.text('INTEGRATED LOUDNESS GAUGE'), findsOneWidget);
      expect(find.text('TRUE-PEAK GUARD'), findsOneWidget);
    });
  });
}
