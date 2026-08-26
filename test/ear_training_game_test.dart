import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/intelligence/presentation/ear_training_game_dialog.dart';

void main() {
  group('EarTrainingGame Tests', () {
    testWidgets('EarTrainingGameDialog renders questions and test tone buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EarTrainingGameDialog(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('STUDIO MUSICIAN EAR TRAINING GAME'), findsOneWidget);
      expect(find.text('FREQUENCY DISCRIMINATION'), findsOneWidget);
      expect(find.text('Which frequency band was boosted in this audio sample?'), findsOneWidget);
      expect(find.text('PLAY TEST TONE (1200Hz)'), findsOneWidget);
      expect(find.text('1.2 kHz (Vocal Presence Mid)'), findsOneWidget);

      // Select option
      await tester.tap(find.text('1.2 kHz (Vocal Presence Mid)'));
      await tester.pumpAndSettle();

      expect(find.text('NEXT QUESTION'), findsOneWidget);
    });
  });
}
