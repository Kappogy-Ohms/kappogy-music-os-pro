import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/theme/skeuomorphic_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/skeuo_brand_logo.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../../documentation/presentation/studio_guide_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _strictOfflineMode = true;
  bool _gaplessPlayback = true;
  bool _crossfade = false;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeuoButton(
          size: 40,
          isCircular: false,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'OS SETTINGS & SYSTEM PREFERENCES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Selector
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INTERFACE THEME & HARDWARE STYLING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SkeuoRockerSwitch<AppThemeMode>(
                        options: const [
                          RockerOption(value: AppThemeMode.skeuomorphicDark, label: 'Skeuo Studio'),
                          RockerOption(value: AppThemeMode.amoledMidnight, label: 'AMOLED Black'),
                          RockerOption(value: AppThemeMode.retroWin95, label: 'Win95 Retro'),
                          RockerOption(value: AppThemeMode.cyberNeon, label: 'Cyber Neon'),
                        ],
                        selectedValue: currentTheme,
                        activeColor: AppColors.kappogyYellow,
                        onSelected: (mode) => themeNotifier.setTheme(mode),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Privacy & Strict Offline Mode
              SkeuoPanel(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'STRICT OFFLINE MODE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        'Blocks all network sockets and forces 100% on-device operations',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      value: _strictOfflineMode,
                      activeThumbColor: AppColors.kappogyGreen,
                      onChanged: (val) {
                        setState(() => _strictOfflineMode = val);
                      },
                    ),
                    const Divider(color: AppColors.borderSubtle),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'GAPLESS PLAYBACK',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        'Seamless transition between tracks without audio silence',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      value: _gaplessPlayback,
                      activeThumbColor: AppColors.ledCyan,
                      onChanged: (val) {
                        setState(() => _gaplessPlayback = val);
                      },
                    ),
                    const Divider(color: AppColors.borderSubtle),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'AUDIO CROSSFADING (3s)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        'Smooth volume blend during track changes',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      value: _crossfade,
                      activeThumbColor: AppColors.kappogyYellow,
                      onChanged: (val) {
                        setState(() => _crossfade = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Documentation & Feedback Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Tooltip(
                  message: 'Open user guide, hardware keybindings, updates, and feedback to developer Kappogy Ohms',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.panelRaised,
                      side: const BorderSide(color: AppColors.kappogyYellow, width: 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, color: AppColors.kappogyYellow, size: 18),
                    label: const Text(
                      'STUDIO USER GUIDE & IN-APP UPDATES',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudioGuideScreen()));
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // About & Brand Card
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(20.0),
                child: const Column(
                  children: [
                    Center(child: SkeuoBrandLogo(size: 48)),
                    SizedBox(height: 12),
                    Text(
                      'Kappogy Music OS Pro is a private, intelligent, local-first music operating system engineered with tactile hardware ergonomics and 60fps audio processing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Developer: Kappogy Ohms • Contact: kappogyohms@gmail.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Version 2.4.0 Studio Pro • 100% Offline Core',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
