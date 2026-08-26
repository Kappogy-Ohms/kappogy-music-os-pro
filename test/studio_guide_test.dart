import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/documentation/presentation/studio_guide_screen.dart';

void main() {
  testWidgets('StudioGuideScreen displays documentation, switches tabs, and handles update check', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StudioGuideScreen(),
        ),
      ),
    );

    // Initial guide tab
    expect(find.text('STUDIO DOCUMENTATION & FEEDBACK'), findsOneWidget);
    expect(find.text('1. TURNTABLE VINYL & AUDIO PLAYER ENGINE'), findsOneWidget);
    expect(find.text('2. 10-BAND GRAPHIC EQUALIZER & SPLINE CURVE'), findsOneWidget);

    // Switch to Shortcuts & Hotkeys tab
    await tester.tap(find.text('⌨️ SHORTCUTS & HOTKEYS'));
    await tester.pumpAndSettle();

    expect(find.text('STUDIO HARDWARE KEYBINDINGS (DESKTOP / TABLET)'), findsOneWidget);
    expect(find.text('Spacebar'), findsOneWidget);
    expect(find.text('Toggle Play / Pause'), findsOneWidget);

    // Switch to In-App Updates tab
    await tester.tap(find.text('🔄 IN-APP UPDATES'));
    await tester.pumpAndSettle();

    expect(find.text('Version 2.4.0 (Studio Release)'), findsOneWidget);
    expect(find.text('Developer: Kappogy Ohms'), findsOneWidget);
    expect(find.text('CHECK FOR UPDATES (OFFLINE SAFE)'), findsOneWidget);

    // Switch to User Feedback tab
    await tester.tap(find.text('💬 USER FEEDBACK'));
    await tester.pumpAndSettle();

    expect(find.text('OFFLINE USER FEEDBACK & HARDWARE PROFILES'), findsOneWidget);
    expect(find.text('ADMIN: kappogyohms@gmail.com'), findsOneWidget);
    expect(find.text('SEND VIA EMAIL'), findsOneWidget);
    expect(find.text('COPY DIAGNOSTICS'), findsOneWidget);
  });
}
