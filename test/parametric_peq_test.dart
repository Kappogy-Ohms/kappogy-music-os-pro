import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/parametric_peq_sheet.dart';

void main() {
  group('ParametricPeq Tests', () {
    test('ParametricPeqNotifier updates bands and resets flat', () {
      final notifier = ParametricPeqNotifier();

      expect(notifier.state.isMasterEnabled, isTrue);
      expect(notifier.state.bands.length, equals(5));

      notifier.selectBand(1);
      expect(notifier.state.activeBandIndex, equals(1));

      notifier.updateActiveBand(freq: 500.0, gain: 6.0, q: 2.5);
      expect(notifier.state.bands[1].frequencyHz, equals(500.0));
      expect(notifier.state.bands[1].gainDb, equals(6.0));
      expect(notifier.state.bands[1].qFactor, equals(2.5));

      notifier.resetFlat();
      expect(notifier.state.bands[1].gainDb, equals(0.0));
    });

    testWidgets('ParametricPeqSheet renders continuous spline and knobs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ParametricPeqSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('5-BAND CONTINUOUS PARAMETRIC EQUALIZER (PEQ)'), findsOneWidget);
      expect(find.text('SELECT PARAMETRIC BAND'), findsOneWidget);
      expect(find.text('FREQ'), findsOneWidget);
      expect(find.text('GAIN'), findsOneWidget);
      expect(find.text('Q-FACTOR'), findsOneWidget);
    });
  });
}
