import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/cassette_deck_sheet.dart';

void main() {
  group('CassetteDeck Tests', () {
    test('CassetteDeckNotifier updates tape formulations and wow/flutter', () {
      final notifier = CassetteDeckNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.tapeType, equals(CassetteTapeType.typeIFerric));

      notifier.setTapeType(CassetteTapeType.typeIVMetal);
      expect(notifier.state.tapeType, equals(CassetteTapeType.typeIVMetal));

      notifier.setWowFlutter(45.0);
      expect(notifier.state.wowFlutterPercent, equals(45.0));

      notifier.setTapeWear(60.0);
      expect(notifier.state.tapeWearPercent, equals(60.0));

      notifier.setBias(8.0);
      expect(notifier.state.motorBiasGainDb, equals(8.0));
    });

    testWidgets('CassetteDeckSheet renders cassette spools and tape controls', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CassetteDeckSheet(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('VINTAGE CASSETTE DECK & LO-FI MODULATOR'), findsOneWidget);
      expect(find.text('MAGNETIC TAPE FORMULATION'), findsOneWidget);
      expect(find.text('WOW/FLUTTER'), findsOneWidget);
      expect(find.text('TAPE WEAR'), findsOneWidget);
      expect(find.text('BIAS GAIN'), findsOneWidget);
    });
  });
}
