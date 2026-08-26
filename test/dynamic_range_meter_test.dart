import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/core/audio/dynamic_range_analyzer.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/dynamic_range_meter_sheet.dart';

void main() {
  group('DynamicRangeAnalyzer Tests', () {
    test('DynamicRangeReport accurately assigns grades across DR scores', () {
      final audiophile = DynamicRangeReport.evaluate(trackTitle: 'Test', customDr: 16);
      expect(audiophile.grade, equals(DynamicGrade.audiophileMaster));
      expect(audiophile.drScore, equals(16));

      final balanced = DynamicRangeReport.evaluate(trackTitle: 'Test', customDr: 11);
      expect(balanced.grade, equals(DynamicGrade.balanced));

      final moderate = DynamicRangeReport.evaluate(trackTitle: 'Test', customDr: 7);
      expect(moderate.grade, equals(DynamicGrade.moderate));

      final brickwalled = DynamicRangeReport.evaluate(trackTitle: 'Test', customDr: 4);
      expect(brickwalled.grade, equals(DynamicGrade.brickwalled));
    });

    test('analyzeSamples calculates RMS and Peak from sample buffers', () {
      final samples = List.generate(100, (i) => (i % 2 == 0 ? 0.5 : -0.5));
      final report = DynamicRangeReport.analyzeSamples(samples, trackTitle: 'Square Wave');
      expect(report.peakDbfs, greaterThan(-10.0));
      expect(report.rmsDbfs, greaterThan(-10.0));
      expect(report.drScore, greaterThanOrEqualTo(1));
    });

    testWidgets('DynamicRangeMeterSheet renders DR gauge and metrics', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicRangeMeterSheet(),
            ),
          ),
        ),
      );

      expect(find.text('AUDIOPHILE DYNAMIC RANGE (DR) METER'), findsOneWidget);
      expect(find.text('PEAK LEVEL'), findsOneWidget);
      expect(find.text('RMS LOUDNESS'), findsOneWidget);
      expect(find.text('CREST FACTOR'), findsOneWidget);
    });
  });
}
