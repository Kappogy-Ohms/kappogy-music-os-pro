import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Studio Rack Chassis Panel with Specular Highlights and Inset Wells
class SkeuoPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final String? title;
  final Widget? headerAction;
  final bool isSunken;
  final BorderRadius? borderRadius;
  final bool showCornerScrews;

  const SkeuoPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.width,
    this.height,
    this.title,
    this.headerAction,
    this.isSunken = false,
    this.borderRadius,
    this.showCornerScrews = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16.0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isSunken ? AppColors.panelSunken : AppColors.panelRaised,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: isSunken ? AppColors.borderSubtle : AppColors.borderProminent,
          width: 1.2,
        ),
        boxShadow: isSunken
            ? SkeuoTokens.sunkenWell
            : [
                ...SkeuoTokens.raisedMd,
                const BoxShadow(
                  color: AppColors.highlightSharp,
                  offset: Offset(-1, -1),
                  blurRadius: 1,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Stack(
        children: [
          // Corner Studio Screws
          if (showCornerScrews) ...[
            const Positioned(top: 8, left: 8, child: _StudioScrew()),
            const Positioned(top: 8, right: 8, child: _StudioScrew()),
            const Positioned(bottom: 8, left: 8, child: _StudioScrew()),
            const Positioned(bottom: 8, right: 8, child: _StudioScrew()),
          ],

          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null || headerAction != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Text(
                          title!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.0,
                            shadows: SkeuoTokens.debossedText,
                          ),
                        ),
                      if (headerAction != null) headerAction!,
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioScrew extends StatelessWidget {
  const _StudioScrew();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF222530),
        boxShadow: SkeuoTokens.sunkenWell,
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 1,
          color: const Color(0xFF4A5064),
        ),
      ),
    );
  }
}
