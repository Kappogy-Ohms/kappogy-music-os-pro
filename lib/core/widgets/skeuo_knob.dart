import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Tactile Rotary Potentiometer / Encoder with 270° Radial LED Ring.
class SkeuoKnob extends StatefulWidget {
  final double value; // Between min and max
  final double min;
  final double max;
  final String label;
  final String? displayValue;
  final ValueChanged<double> onChanged;
  final double size;
  final Color ledColor;
  final int tickCount;

  const SkeuoKnob({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    required this.label,
    this.displayValue,
    required this.onChanged,
    this.size = 110.0,
    this.ledColor = AppColors.ledCyan,
    this.tickCount = 28,
  });

  @override
  State<SkeuoKnob> createState() => _SkeuoKnobState();
}

class _SkeuoKnobState extends State<SkeuoKnob> {
  double _dragStartY = 0.0;
  double _dragStartValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final normalized = ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    // 270 degree total sweep: from -135° to +135°
    final angle = -135.0 + (normalized * 270.0);
    final dialSize = widget.size * 0.64;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragStart: (details) {
            _dragStartY = details.globalPosition.dy;
            _dragStartValue = widget.value;
          },
          onVerticalDragUpdate: (details) {
            final deltaY = _dragStartY - details.globalPosition.dy;
            final range = widget.max - widget.min;
            final step = (deltaY / 140.0) * range;
            final newValue = (_dragStartValue + step).clamp(widget.min, widget.max);
            widget.onChanged(newValue);
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.panelSunken,
              boxShadow: SkeuoTokens.sunkenWell,
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 270° Radial LED Ticks
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _KnobTickPainter(
                    normalizedValue: normalized,
                    tickCount: widget.tickCount,
                    activeColor: widget.ledColor,
                    inactiveColor: AppColors.ledInactive,
                  ),
                ),

                // Raised Rotating Dial Body
                Transform.rotate(
                  angle: angle * (pi / 180.0),
                  child: Container(
                    width: dialSize,
                    height: dialSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.knobDialGradient,
                      border: Border.all(
                        color: AppColors.borderProminent,
                        width: 1.2,
                      ),
                      boxShadow: SkeuoTokens.raisedLg,
                    ),
                    child: Stack(
                      children: [
                        // Indicator Pip / Milled LED notch
                        Align(
                          alignment: const Alignment(0, -0.75),
                          child: Container(
                            width: 3.5,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: widget.ledColor,
                              borderRadius: BorderRadius.circular(2.0),
                              boxShadow: SkeuoTokens.ledGlow(widget.ledColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Numerical Readout (Non-rotating)
                IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.displayValue ??
                            (widget.max <= 10
                                ? widget.value.toStringAsFixed(1)
                                : widget.value.round().toString()),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          shadows: SkeuoTokens.debossedText,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
      ],
    );
  }
}

class _KnobTickPainter extends CustomPainter {
  final double normalizedValue;
  final int tickCount;
  final Color activeColor;
  final Color inactiveColor;

  _KnobTickPainter({
    required this.normalizedValue,
    required this.tickCount,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8.0;
    const sweepAngle = 270.0;
    const startAngle = 135.0; // 135° in standard polar is bottom-left

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    for (int i = 0; i < tickCount; i++) {
      final t = i / (tickCount - 1);
      final currentAngleDeg = startAngle + (t * sweepAngle);
      final currentAngleRad = currentAngleDeg * (pi / 180.0);

      final isActive = t <= normalizedValue;

      if (isActive) {
        paint.color = activeColor;
      } else {
        paint.color = inactiveColor;
      }

      final p1 = Offset(
        center.dx + (radius - 5.0) * cos(currentAngleRad),
        center.dy + (radius - 5.0) * sin(currentAngleRad),
      );
      final p2 = Offset(
        center.dx + radius * cos(currentAngleRad),
        center.dy + radius * sin(currentAngleRad),
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _KnobTickPainter oldDelegate) {
    return oldDelegate.normalizedValue != normalizedValue ||
        oldDelegate.activeColor != activeColor;
  }
}
