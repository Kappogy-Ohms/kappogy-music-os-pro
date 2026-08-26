import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Tactile Channel Fader (Vertical Equalizer & Mixer Slider)
class SkeuoFader extends StatefulWidget {
  final double value; // -15.0 to +15.0 or 0.0 to 1.0
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;
  final double height;
  final double width;
  final Color ledColor;
  final bool showScale;

  const SkeuoFader({
    super.key,
    required this.value,
    this.min = -15.0,
    this.max = 15.0,
    required this.label,
    required this.onChanged,
    this.height = 180.0,
    this.width = 44.0,
    this.ledColor = AppColors.ledBlue,
    this.showScale = true,
  });

  @override
  State<SkeuoFader> createState() => _SkeuoFaderState();
}

class _SkeuoFaderState extends State<SkeuoFader> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final normalized = ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    const capHeight = 36.0;
    final trackTravel = widget.height - capHeight;
    // Invert so high value is at top
    final capTop = (1.0 - normalized) * trackTravel;

    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scale max label
          if (widget.showScale)
            Text(
              '+${widget.max.toInt()}dB',
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                shadows: SkeuoTokens.debossedText,
              ),
            ),
          const SizedBox(height: 4),

          // Fader Trench & Slider Cap
          GestureDetector(
            onVerticalDragStart: (details) {
              setState(() => _isDragging = true);
              _handleDrag(details.localPosition.dy, trackTravel);
            },
            onVerticalDragUpdate: (details) {
              _handleDrag(details.localPosition.dy, trackTravel);
            },
            onVerticalDragEnd: (_) {
              setState(() => _isDragging = false);
            },
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Milled Vertical Groove / Slot
                  Center(
                    child: Container(
                      width: 8.0,
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: AppColors.panelWell,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: SkeuoTokens.sunkenWell,
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 0dB Center Reference Indicator
                          Container(
                            width: 12.0,
                            height: 1.5,
                            color: AppColors.borderProminent,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3D Raised Fader Cap
                  Positioned(
                    top: capTop,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 40),
                      width: 32.0,
                      height: capHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        gradient: AppColors.raisedButtonGradient,
                        border: Border.all(
                          color: _isDragging
                              ? widget.ledColor.withValues(alpha: 0.6)
                              : AppColors.borderProminent,
                          width: 1.2,
                        ),
                        boxShadow: _isDragging
                            ? [
                                ...SkeuoTokens.raisedSm,
                                BoxShadow(
                                  color: widget.ledColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : SkeuoTokens.raisedMd,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Upper Grip Line
                          Container(
                            width: 14.0,
                            height: 1.5,
                            color: Colors.black54,
                          ),
                          const SizedBox(height: 3),
                          // Glowing Center LED Marker
                          Container(
                            width: 18.0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: widget.ledColor,
                              borderRadius: BorderRadius.circular(1.0),
                              boxShadow: SkeuoTokens.ledGlow(widget.ledColor),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Lower Grip Line
                          Container(
                            width: 14.0,
                            height: 1.5,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),
          // Scale min label
          if (widget.showScale)
            Text(
              '${widget.min.toInt()}dB',
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                shadows: SkeuoTokens.debossedText,
              ),
            ),
          const SizedBox(height: 6),

          // Channel Title / Frequency Band Label
          Text(
            widget.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              shadows: SkeuoTokens.debossedText,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDrag(double localY, double trackTravel) {
    const capHeight = 36.0;
    final clampedY = (localY - (capHeight / 2)).clamp(0.0, trackTravel);
    final normalized = 1.0 - (clampedY / trackTravel); // 0 at bottom, 1 at top
    final newValue = widget.min + (normalized * (widget.max - widget.min));
    widget.onChanged(newValue);
  }
}
