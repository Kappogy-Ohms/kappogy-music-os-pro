import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/skeuomorphic_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/library/data/music_database.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for Desktop (Windows / Linux / macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Ensure database & demo tracks initialized
  await MusicDatabase.instance.database;

  // System UI Overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.chassisBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: KappogyMusicOsApp()));
}

class KappogyMusicOsApp extends ConsumerWidget {
  const KappogyMusicOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Kappogy Music OS Pro',
      debugShowCheckedModeBanner: false,
      theme: KappogyTheme.getTheme(currentThemeMode),
      home: const SplashScreen(),
    );
  }
}
