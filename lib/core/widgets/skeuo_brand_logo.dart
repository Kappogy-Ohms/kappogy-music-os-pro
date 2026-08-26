import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Official Kappogy Studio Emblem
/// Features the Black Ω (Ohm) insignia with illuminated Tri-Color Gradient halo.
class SkeuoBrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isCompact;

  const SkeuoBrandLogo({
    super.key,
    this.size = 36.0,
    this.showText = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3D Embossed Ω Emblem with Tri-Color Accent Ring
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.raisedButtonGradient,
            border: Border.all(
              color: AppColors.borderProminent,
              width: 1.5,
            ),
            boxShadow: [
              ...SkeuoTokens.raisedMd,
              BoxShadow(
                color: AppColors.kappogyRed.withValues(alpha: 0.2),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: AppColors.kappogyGreen.withValues(alpha: 0.2),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => AppColors.kappogyGradient.createShader(bounds),
              child: Text(
                'Ω',
                style: TextStyle(
                  fontSize: size * 0.58,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'KAPPOGY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: AppColors.textPrimary,
                      shadows: SkeuoTokens.debossedText,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.kappogyYellow,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isCompact)
                const Text(
                  'OFFLINE MUSIC OS',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
