import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/dj_mode/presentation/automix_engine_sheet.dart';

void main() {
  group('AutomixEngine Tests', () {
    test('AutomixNotifier updates transition styles and toggles', () {
      final notifier = AutomixNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.style, equals(AutomixTransitionStyle.beatmatch8Bar));

      notifier.setStyle(AutomixTransitionStyle.highPassSweep);
      expect(notifier.state.style, equals(AutomixTransitionStyle.highPassSweep));

      notifier.setTransitionDuration(16.0);
      expect(notifier.state.transitionSeconds, equals(16.0));

      notifier.toggleHarmonicSort();
      expect(notifier.state.isHarmonicSortEnabled, isFalse);

      notifier.toggleBpmMatch();
      expect(notifier.state.isTempoBpmMatchEnabled, isFalse);
    });

    testWidgets('AutomixEngineSheet renders style rockers and transition knobs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AutomixEngineSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DJ AUTOMIX & HARMONIC TRANSITION ENGINE'), findsOneWidget);
      expect(find.text('AUTOMIX TRANSITION STYLE'), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('HARMONIC CAMELOT SORT'), findsOneWidget);
      expect(find.text('BPM TEMPO SYNC'), findsOneWidget);
    });
  });
}
