import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Segmented Mechanical Rocker Switch / Preset Bar
class SkeuoRockerSwitch<T> extends StatelessWidget {
  final List<RockerOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double height;
  final Color activeColor;

  const SkeuoRockerSwitch({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.height = 42.0,
    this.activeColor = AppColors.ledCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: AppColors.panelSunken,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: SkeuoTokens.sunkenWell,
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = opt.value == selectedValue;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              onTap: () => onSelected(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  gradient: isSelected
                      ? AppColors.pressedButtonGradient
                      : AppColors.raisedButtonGradient,
                  border: Border.all(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.5)
                        : AppColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          ...SkeuoTokens.pressedDepth,
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ]
                      : SkeuoTokens.raisedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (opt.icon != null) ...[
                      Icon(
                        opt.icon,
                        size: 14,
                        color: isSelected ? activeColor : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      opt.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? activeColor : AppColors.textSecondary,
                        letterSpacing: 0.4,
                        shadows: isSelected
                            ? [
                                Shadow(
                                  color: activeColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : SkeuoTokens.debossedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RockerOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const RockerOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
