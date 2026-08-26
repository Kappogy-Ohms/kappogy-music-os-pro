import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/equalizer/presentation/spatial_audio_sheet.dart';

void main() {
  group('SpatialAudio Tests', () {
    test('SpatialAudioNotifier clamps and updates 3D orbit angles', () {
      final notifier = SpatialAudioNotifier();

      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.profile, equals(SpatialHrtfProfile.genericStudio));

      notifier.setAzimuth(180.0);
      expect(notifier.state.azimuthDegrees, equals(180.0));

      notifier.setElevation(25.0);
      expect(notifier.state.elevationDegrees, equals(25.0));

      notifier.setDistance(4.5);
      expect(notifier.state.distanceMeters, equals(4.5));

      notifier.setProfile(SpatialHrtfProfile.binauralCinema);
      expect(notifier.state.profile, equals(SpatialHrtfProfile.binauralCinema));
    });

    testWidgets('SpatialAudioSheet renders 360 radar disk and HRTF presets', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SpatialAudioSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BINAURAL 3D SPATIAL AUDIO & ORBIT SIMULATOR'), findsOneWidget);
      expect(find.text('360° SPATIAL ORBIT RADAR'), findsOneWidget);
      expect(find.text('HRTF ACOUSTIC PROFILE'), findsOneWidget);
      expect(find.text('AZIMUTH'), findsOneWidget);
      expect(find.text('ELEVATION'), findsOneWidget);
      expect(find.text('DISTANCE'), findsOneWidget);
    });
  });
}
