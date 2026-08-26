import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/analog_warmer_sheet.dart';

void main() {
  group('AnalogWarmer Tests', () {
    test('AnalogWarmerNotifier updates tube warmth and profile', () {
      final notifier = AnalogWarmerNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.profile, equals(WarmthChassisProfile.vintageTube75));

      notifier.setProfile(WarmthChassisProfile.studerTapeMaster);
      expect(notifier.state.profile, equals(WarmthChassisProfile.studerTapeMaster));

      notifier.setTubeWarmth(65.0);
      expect(notifier.state.tubeWarmthPercent, equals(65.0));

      notifier.setTapeSaturation(80.0);
      expect(notifier.state.tapeSaturationPercent, equals(80.0));

      notifier.setDrive(12.5);
      expect(notifier.state.harmonicDriveDb, equals(12.5));

      notifier.toggleHiss();
      expect(notifier.state.isAnalogHissEnabled, isTrue);
    });

    testWidgets('AnalogWarmerSheet renders profile cards and potentiometers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnalogWarmerSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('VINTAGE TUBE & TAPE SATURATION WARMER'), findsOneWidget);
      expect(find.text('ANALOG CHASSIS & VALVE PROFILE'), findsOneWidget);
      expect(find.text('TUBE WARMTH'), findsOneWidget);
      expect(find.text('TAPE GLUE'), findsOneWidget);
      expect(find.text('DRIVE'), findsOneWidget);
    });
  });
}
