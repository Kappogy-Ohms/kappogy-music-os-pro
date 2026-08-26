import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/main.dart';

void main() {
  testWidgets('Kappogy Music OS App initializes properly with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KappogyMusicOsApp(),
      ),
    );

    // Initial frame pump
    await tester.pump(const Duration(milliseconds: 100));

    // Verify splash screen branding exists
    expect(find.text('KAPPOGY MUSIC OS'), findsOneWidget);
    expect(find.text('PRO EDITION'), findsOneWidget);
    expect(find.text('Ω'), findsWidgets);

    // Advance time past the splash delay (2200ms)
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 700));

    // Verify home screen loaded
    expect(find.text('KAPPOGY'), findsWidgets);
  });
}
