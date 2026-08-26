import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/ab_looper_sheet.dart';

void main() {
  group('AbLooper Tests', () {
    test('AbLoopNotifier sets Point A, Point B, and toggles active state', () {
      final notifier = AbLoopNotifier();

      expect(notifier.state.pointAms, isNull);
      expect(notifier.state.pointBms, isNull);
      expect(notifier.state.isLoopActive, isFalse);

      notifier.setPointA(5000);
      expect(notifier.state.pointAms, equals(5000));
      expect(notifier.state.isLoopActive, isFalse);

      notifier.setPointB(15000);
      expect(notifier.state.pointBms, equals(15000));
      expect(notifier.state.isLoopActive, isTrue);

      notifier.nudgePointA(100, 30000);
      expect(notifier.state.pointAms, equals(5100));

      notifier.nudgePointB(-200, 30000);
      expect(notifier.state.pointBms, equals(14800));

      notifier.setSpeed(0.75);
      expect(notifier.state.practiceSpeed, equals(0.75));

      notifier.clearLoop();
      expect(notifier.state.pointAms, isNull);
      expect(notifier.state.pointBms, isNull);
      expect(notifier.state.isLoopActive, isFalse);
    });

    testWidgets('AbLooperSheet renders action buttons and timeline display', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AbLooperSheet(),
            ),
          ),
        ),
      );

      expect(find.text('PRECISION A-B STUDIO LOOPER & PRACTICE DECK'), findsOneWidget);
      expect(find.text('SET POINT A [IN]'), findsOneWidget);
      expect(find.text('SET POINT B [OUT]'), findsOneWidget);
      expect(find.text('LOOP ON'), findsOneWidget);
    });
  });
}
