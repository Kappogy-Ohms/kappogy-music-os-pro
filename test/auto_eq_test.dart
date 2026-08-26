import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/equalizer/data/auto_eq_database.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/auto_eq_sheet.dart';

void main() {
  group('AutoEQ Tests', () {
    test('AutoEqDatabase contains valid profiles with 10 bands and PEQ filters', () {
      expect(AutoEqDatabase.profiles.isNotEmpty, isTrue);
      for (final p in AutoEqDatabase.profiles) {
        expect(p.graphic10BandGains.length, equals(10));
        expect(p.peqFilters.length, equals(5));
        expect(p.brand.isNotEmpty, isTrue);
        expect(p.model.isNotEmpty, isTrue);
      }
    });

    testWidgets('AutoEqSheet renders brand chips and apply buttons', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AutoEqSheet(),
            ),
          ),
        ),
      );

      expect(find.text('AUDIOPHILE AUTOEQ CORRECTION SUITE'), findsOneWidget);
      expect(find.text('APPLY 10-BAND EQ'), findsOneWidget);
      expect(find.text('APPLY 5-BAND PEQ'), findsOneWidget);
      expect(find.text('ALL'), findsOneWidget);
    });
  });
}
