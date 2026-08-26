import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/audio_player/domain/turntable_theme_model.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/turntable_visualizer.dart';

void main() {
  group('DeckVisualizerTheme Tests', () {
    test('DeckVisualizerThemeNotifier switches themes properly', () {
      final notifier = DeckVisualizerThemeNotifier();
      expect(notifier.state, equals(DeckVisualizerTheme.classicStudio));

      notifier.setTheme(DeckVisualizerTheme.technics1200);
      expect(notifier.state, equals(DeckVisualizerTheme.technics1200));

      notifier.setTheme(DeckVisualizerTheme.reelToReel);
      expect(notifier.state, equals(DeckVisualizerTheme.reelToReel));

      notifier.setTheme(DeckVisualizerTheme.clearaudioAcrylic);
      expect(notifier.state, equals(DeckVisualizerTheme.clearaudioAcrylic));

      notifier.setTheme(DeckVisualizerTheme.neonCyber);
      expect(notifier.state, equals(DeckVisualizerTheme.neonCyber));
    });

    testWidgets('TurntableVisualizer renders with classicStudio and reelToReel themes', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: TurntableVisualizer(
                  size: 220,
                  isPlaying: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TurntableVisualizer), findsOneWidget);

      // Switch to Reel-to-Reel
      container.read(deckVisualizerThemeProvider.notifier).setTheme(DeckVisualizerTheme.reelToReel);
      await tester.pump();

      expect(find.byType(TurntableVisualizer), findsOneWidget);
    });
  });
}
