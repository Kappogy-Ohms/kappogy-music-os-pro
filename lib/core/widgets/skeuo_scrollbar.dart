import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 90s/2000s Skeuomorphic Tactile Scrollbar for Desktop and Tablet Lists
class SkeuoScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  const SkeuoScrollbar({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 12.0,
      radius: const Radius.circular(6.0),
      thumbColor: const Color(0xFF343847),
      trackColor: AppColors.panelSunken,
      trackBorderColor: AppColors.borderSubtle,
      trackRadius: const Radius.circular(6.0),
      interactive: true,
      child: child,
    );
  }
}

/// Global Theme Scrollbar Configuration for Kappogy Skeuomorphism
class KappogyScrollbarTheme {
  static ScrollbarThemeData get theme => ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(12.0),
        radius: const Radius.circular(6.0),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return AppColors.kappogyRed; // Kappogy active LED red
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFF454B5E);
          }
          return const Color(0xFF2E3240);
        }),
        trackColor: WidgetStateProperty.all(AppColors.panelSunken),
        trackBorderColor: WidgetStateProperty.all(AppColors.borderSubtle),
      );
}
