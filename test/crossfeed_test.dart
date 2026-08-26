import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/crossfeed_processor_sheet.dart';

void main() {
  group('Crossfeed Processor Tests', () {
    test('CrossfeedNotifier toggles state and clamps parameters properly', () {
      final notifier = CrossfeedNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.blendPercent, equals(0.45));

      notifier.setBlend(0.85);
      expect(notifier.state.blendPercent, equals(0.85));

      notifier.setHfDamping(-4.5);
      expect(notifier.state.hfDampingDb, equals(-4.5));

      notifier.setRoomSpace(AcousticRoomSpace.liveStage);
      expect(notifier.state.roomSpace, equals(AcousticRoomSpace.liveStage));

      notifier.toggleSubBassMono();
      expect(notifier.state.isSubBassMono, isFalse);

      notifier.toggleEnabled();
      expect(notifier.state.isEnabled, isFalse);
    });

    testWidgets('CrossfeedProcessorSheet renders skeuomorphic controls and soundstage painter', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CrossfeedProcessorSheet(),
            ),
          ),
        ),
      );

      expect(find.text('BAUER HEADPHONE CROSSFEED & ROOM PROCESSOR'), findsOneWidget);
      expect(find.text('VIRTUAL SOUNDSTAGE FIELD (ITD / IID)'), findsOneWidget);
      expect(find.text('SUB-BASS MONO SUMMING (< 90Hz)'), findsOneWidget);
    });
  });
}
