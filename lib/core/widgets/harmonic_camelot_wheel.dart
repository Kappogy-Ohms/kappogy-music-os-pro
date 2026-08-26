import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

enum HarmonicRelation { exact, adjacent, relative, energyBoost, incompatible }

class CamelotKeyInfo {
  final int number; // 1 to 12
  final String letter; // 'A' or 'B'
  final String musicalKey; // e.g. 'Am', 'C'

  const CamelotKeyInfo(this.number, this.letter, this.musicalKey);

  String get code => '$number$letter';

  HarmonicRelation getRelationTo(CamelotKeyInfo other) {
    if (number == other.number && letter == other.letter) {
      return HarmonicRelation.exact;
    }
    if (letter == other.letter) {
      final diff = (number - other.number).abs();
      if (diff == 1 || diff == 11) return HarmonicRelation.adjacent;
      if ((number - other.number + 12) % 12 == 2) return HarmonicRelation.energyBoost;
    }
    if (number == other.number && letter != other.letter) {
      return HarmonicRelation.relative;
    }
    return HarmonicRelation.incompatible;
  }
}

/// 24-Key Interactive Camelot Harmonic Mixing Wheel
class HarmonicCamelotWheel extends StatelessWidget {
  final String activeKey; // e.g. '8A' or 'Am'
  final ValueChanged<String>? onKeySelected;
  final double size;

  const HarmonicCamelotWheel({
    super.key,
    required this.activeKey,
    this.onKeySelected,
    this.size = 280.0,
  });

  static const List<CamelotKeyInfo> minorKeys = [
    CamelotKeyInfo(1, 'A', 'Abm'),
    CamelotKeyInfo(2, 'A', 'Ebm'),
    CamelotKeyInfo(3, 'A', 'Bbm'),
    CamelotKeyInfo(4, 'A', 'Fm'),
    CamelotKeyInfo(5, 'A', 'Cm'),
    CamelotKeyInfo(6, 'A', 'Gm'),
    CamelotKeyInfo(7, 'A', 'Dm'),
    CamelotKeyInfo(8, 'A', 'Am'),
    CamelotKeyInfo(9, 'A', 'Em'),
    CamelotKeyInfo(10, 'A', 'Bm'),
    CamelotKeyInfo(11, 'A', 'F#m'),
    CamelotKeyInfo(12, 'A', 'Dbm'),
  ];

  static const List<CamelotKeyInfo> majorKeys = [
    CamelotKeyInfo(1, 'B', 'B'),
    CamelotKeyInfo(2, 'B', 'F#'),
    CamelotKeyInfo(3, 'B', 'Db'),
    CamelotKeyInfo(4, 'B', 'Ab'),
    CamelotKeyInfo(5, 'B', 'Eb'),
    CamelotKeyInfo(6, 'B', 'Bb'),
    CamelotKeyInfo(7, 'B', 'F'),
    CamelotKeyInfo(8, 'B', 'C'),
    CamelotKeyInfo(9, 'B', 'G'),
    CamelotKeyInfo(10, 'B', 'D'),
    CamelotKeyInfo(11, 'B', 'A'),
    CamelotKeyInfo(12, 'B', 'E'),
  ];

  CamelotKeyInfo? _parseKey(String key) {
    final clean = key.trim().toUpperCase();
    for (final k in [...minorKeys, ...majorKeys]) {
      if (k.code.toUpperCase() == clean || k.musicalKey.toUpperCase() == clean) {
        return k;
      }
    }
    return const CamelotKeyInfo(8, 'A', 'Am'); // default
  }

  @override
  Widget build(BuildContext context) {
    final activeInfo = _parseKey(activeKey);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.panelSunken,
        boxShadow: SkeuoTokens.sunkenWell,
        border: Border.all(color: AppColors.borderSubtle, width: 2.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring: 1B - 12B (Major)
          ...List.generate(12, (i) {
            final key = majorKeys[i];
            final angle = (i * (360 / 12) - 90) * (pi / 180);
            final radius = size * 0.38;
            final relation = activeInfo != null ? key.getRelationTo(activeInfo) : HarmonicRelation.incompatible;
            return _buildKeySegment(key, angle, radius, relation);
          }),

          // Inner Ring: 1A - 12A (Minor)
          ...List.generate(12, (i) {
            final key = minorKeys[i];
            final angle = (i * (360 / 12) - 90) * (pi / 180);
            final radius = size * 0.24;
            final relation = activeInfo != null ? key.getRelationTo(activeInfo) : HarmonicRelation.incompatible;
            return _buildKeySegment(key, angle, radius, relation);
          }),

          // Center Hub Display
          Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.raisedButtonGradient,
              border: Border.all(color: AppColors.borderProminent, width: 1.5),
              boxShadow: SkeuoTokens.raisedMd,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    activeInfo?.code ?? '8A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.kappogyGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    activeInfo?.musicalKey ?? 'Am',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeySegment(CamelotKeyInfo key, double angle, double radius, HarmonicRelation relation) {
    Color keyColor;
    Color textColor;
    bool isGlow = false;

    switch (relation) {
      case HarmonicRelation.exact:
        keyColor = AppColors.kappogyGreen;
        textColor = Colors.black;
        isGlow = true;
        break;
      case HarmonicRelation.adjacent:
        keyColor = AppColors.ledCyan;
        textColor = Colors.black;
        isGlow = true;
        break;
      case HarmonicRelation.relative:
        keyColor = AppColors.kappogyYellow;
        textColor = Colors.black;
        isGlow = true;
        break;
      case HarmonicRelation.energyBoost:
        keyColor = AppColors.ledPurple;
        textColor = Colors.white;
        isGlow = true;
        break;
      case HarmonicRelation.incompatible:
        keyColor = AppColors.panelRaised;
        textColor = AppColors.textMuted;
        break;
    }

    final x = radius * cos(angle);
    final y = radius * sin(angle);

    return Transform.translate(
      offset: Offset(x, y),
      child: GestureDetector(
        onTap: () => onKeySelected?.call(key.code),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: keyColor,
            border: Border.all(
              color: isGlow ? Colors.white : AppColors.borderSubtle,
              width: isGlow ? 1.5 : 0.8,
            ),
            boxShadow: isGlow
                ? [BoxShadow(color: keyColor.withValues(alpha: 0.6), blurRadius: 8)]
                : SkeuoTokens.raisedSm,
          ),
          child: Center(
            child: Text(
              key.code,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
