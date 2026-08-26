import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/car_mode/presentation/car_mode_screen.dart';

void main() {
  group('CarMode Tests', () {
    testWidgets('CarModeScreen renders oversized transport and driving playlists', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CarModeScreen(),
          ),
        ),
      );

      expect(find.text('CAR MEDIA DASHBOARD'), findsOneWidget);
      expect(find.text('PROGRESS'), findsOneWidget);
      expect(find.text('CAR VOLUME'), findsOneWidget);
      expect(find.text('SMART DRIVING PLAYLISTS (OFFLINE)'), findsOneWidget);
      expect(find.text('HIGHWAY CRUISE'), findsOneWidget);
      expect(find.text('CHILL COMMUTE'), findsOneWidget);
      expect(find.text('UPBEAT ENERGY'), findsOneWidget);
      expect(find.text('ALL FAVORITES'), findsOneWidget);
    });
  });
}
