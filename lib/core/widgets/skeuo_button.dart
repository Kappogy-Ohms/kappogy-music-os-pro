import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Tactile Mechanical Push Button with physical depression depth and 135° key lighting.
class SkeuoButton extends StatefulWidget {
  final Widget? child;
  final IconData? icon;
  final double size;
  final VoidCallback? onPressed;
  final bool isActive;
  final Color? activeColor;
  final String? tooltip;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isCircular;

  const SkeuoButton({
    super.key,
    this.child,
    this.icon,
    this.size = 52.0,
    this.onPressed,
    this.isActive = false,
    this.activeColor,
    this.tooltip,
    this.borderRadius,
    this.padding,
    this.isCircular = true,
  });

  @override
  State<SkeuoButton> createState() => _SkeuoButtonState();
}

class _SkeuoButtonState extends State<SkeuoButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveActive = widget.isActive || _isPressed;
    final effectiveColor = widget.activeColor ?? AppColors.ledCyan;
    final effectiveRadius = widget.borderRadius ??
        (widget.isCircular
            ? BorderRadius.circular(widget.size / 2)
            : BorderRadius.circular(12.0));

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeInOut,
      width: widget.size,
      height: widget.size,
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        gradient: effectiveActive
            ? AppColors.pressedButtonGradient
            : AppColors.raisedButtonGradient,
        border: Border.all(
          color: widget.isActive
              ? effectiveColor.withValues(alpha: 0.6)
              : AppColors.borderSubtle,
          width: 1.2,
        ),
        boxShadow: effectiveActive
            ? [
                ...SkeuoTokens.pressedDepth,
                if (widget.isActive)
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ]
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
      child: Center(
        child: widget.child ??
            (widget.icon != null
                ? Icon(
                    widget.icon,
                    size: widget.size * 0.44,
                    color: widget.isActive
                        ? effectiveColor
                        : (_isPressed
                            ? AppColors.textPrimary
                            : AppColors.textSecondary),
                    shadows: widget.isActive
                        ? [
                            Shadow(
                              color: effectiveColor.withValues(alpha: 0.8),
                              blurRadius: 8,
                            ),
                          ]
                        : SkeuoTokens.debossedText,
                  )
                : const SizedBox.shrink()),
      ),
    );

    if (widget.tooltip != null) {
      content = Tooltip(message: widget.tooltip!, child: content);
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: content,
    );
  }
}
