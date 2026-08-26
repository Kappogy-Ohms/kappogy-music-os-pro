import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_brand_logo.dart';
import '../../../core/widgets/studio_shortcuts_wrapper.dart';
import '../../library/presentation/library_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const StudioShortcutsWrapper(
            child: LibraryScreen(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center 3D Embossed Logo with Tri-Color Glow
            const SkeuoBrandLogo(size: 84)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1.04, 1.04),
                  duration: 1500.ms,
                  curve: Curves.easeInOutSine,
                ),

            const SizedBox(height: 28),

            // Title
            const Text(
              'KAPPOGY MUSIC OS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.5,
                color: AppColors.textPrimary,
                shadows: SkeuoTokens.debossedText,
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0.0),

            const SizedBox(height: 6),

            // Pro Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.panelSunken,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.kappogyRed.withValues(alpha: 0.6), width: 1.2),
                boxShadow: SkeuoTokens.sunkenWell,
              ),
              child: const Text(
                'PRO EDITION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.kappogyRed,
                  letterSpacing: 2.0,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: 14),

            // Subtitle
            const Text(
              '100% OFFLINE STUDIO AUDIO ENGINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.textMuted,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

            const SizedBox(height: 48),

            // Loading Progress Bar
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: AppColors.panelSunken,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.kappogyYellow),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
