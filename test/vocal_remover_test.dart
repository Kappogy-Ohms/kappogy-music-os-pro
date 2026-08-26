import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/lyrics/presentation/vocal_remover_sheet.dart';

void main() {
  group('VocalRemover Tests', () {
    test('VocalRemoverNotifier updates extraction mode and parameters', () {
      final notifier = VocalRemoverNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.mode, equals(VocalExtractionMode.karaokeInstrumental));

      notifier.setMode(VocalExtractionMode.acappellaSolo);
      expect(notifier.state.mode, equals(VocalExtractionMode.acappellaSolo));

      notifier.setVocalCut(-20.0);
      expect(notifier.state.vocalCutDb, equals(-20.0));

      notifier.setCenterFreq(1500.0);
      expect(notifier.state.centerFrequencyHz, equals(1500.0));

      notifier.setSideRecovery(85.0);
      expect(notifier.state.sideStereoRecoveryPercent, equals(85.0));

      notifier.toggleBassRetained();
      expect(notifier.state.isBassRetained, isFalse);
    });

    testWidgets('VocalRemoverSheet renders mode switches and knobs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VocalRemoverSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MID-SIDE VOCAL REMOVER & STEM EXTRACTOR'), findsOneWidget);
      expect(find.text('EXTRACTION MODE'), findsOneWidget);
      expect(find.text('VOCAL CUT'), findsOneWidget);
      expect(find.text('CENTER FREQ'), findsOneWidget);
      expect(find.text('SIDE GLUE'), findsOneWidget);
    });
  });
}
