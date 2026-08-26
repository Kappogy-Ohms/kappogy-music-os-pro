import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/dj_mode/presentation/vinyl_scratch_studio_screen.dart';

void main() {
  group('VinylScratchStudio Tests', () {
    testWidgets('VinylScratchStudioScreen renders dual platters and crossfader', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VinylScratchStudioScreen(),
          ),
        ),
      );

      expect(find.text('LIVE VINYL SCRATCH & JUGGLING STUDIO'), findsOneWidget);
      expect(find.text('DECK A (MASTER)'), findsOneWidget);
      expect(find.text('DECK B (SLAVE)'), findsOneWidget);
      expect(find.text('CUT A (TRANSFORM)'), findsOneWidget);
      expect(find.text('CUT B (TRANSFORM)'), findsOneWidget);
      expect(find.text('VINYL BRAKE'), findsOneWidget);
    });
  });
}
