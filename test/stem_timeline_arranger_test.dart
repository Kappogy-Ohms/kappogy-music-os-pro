import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/dj_mode/presentation/stem_timeline_arranger_sheet.dart';

void main() {
  group('StemTimelineArranger Tests', () {
    testWidgets('StemTimelineArrangerSheet renders 4 stem lanes and loop rockers', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StemTimelineArrangerSheet(),
            ),
          ),
        ),
      );

      expect(find.text('MULTI-STEM TIMELINE & SLICE ARRANGER'), findsOneWidget);
      expect(find.text('VOCALS'), findsOneWidget);
      expect(find.text('DRUMS'), findsOneWidget);
      expect(find.text('BASS'), findsOneWidget);
      expect(find.text('MELODY'), findsOneWidget);
      expect(find.text('BOUNCE & SAVE MIX'), findsOneWidget);
    });
  });
}
