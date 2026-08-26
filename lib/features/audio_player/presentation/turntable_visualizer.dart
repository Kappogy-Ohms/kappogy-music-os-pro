import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../domain/track_model.dart';

/// Tactile Studio Turntable Platter & Vinyl Record Deck
class TurntableVisualizer extends StatefulWidget {
  final Track? track;
  final bool isPlaying;
  final double size;
  final Function(double deltaAngle)? onScratch;

  const TurntableVisualizer({
    super.key,
    this.track,
    this.isPlaying = false,
    this.size = 230.0,
    this.onScratch,
  });

  @override
  State<TurntableVisualizer> createState() => _TurntableVisualizerState();
}

class _TurntableVisualizerState extends State<TurntableVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _manualAngle = 0.0;
  double _lastTouchAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 33 RPM simulated rotation
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant TurntableVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.panelSunken,
        boxShadow: SkeuoTokens.sunkenWell,
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Strobe Dots Platter Edge
          Container(
            width: widget.size * 0.94,
            height: widget.size * 0.94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF1B1D26), Color(0xFF111218)],
              ),
              boxShadow: SkeuoTokens.raisedMd,
              border: Border.all(color: AppColors.borderProminent, width: 1.0),
            ),
          ),

          // Spinning Vinyl Record Body
          GestureDetector(
            onPanStart: (details) {
              final center = Offset(widget.size / 2, widget.size / 2);
              final pos = details.localPosition - center;
              _lastTouchAngle = atan2(pos.dy, pos.dx);
            },
            onPanUpdate: (details) {
              final center = Offset(widget.size / 2, widget.size / 2);
              final pos = details.localPosition - center;
              final currentTouchAngle = atan2(pos.dy, pos.dx);
              final delta = currentTouchAngle - _lastTouchAngle;
              _lastTouchAngle = currentTouchAngle;

              setState(() {
                _manualAngle += delta;
              });
              widget.onScratch?.call(delta);
            },
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                final baseAngle = _rotationController.value * 2 * pi;
                return Transform.rotate(
                  angle: baseAngle + _manualAngle,
                  child: Container(
                    width: widget.size * 0.88,
                    height: widget.size * 0.88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F1014),
                      border: Border.all(color: const Color(0xFF222530), width: 1.0),
                      boxShadow: SkeuoTokens.raisedLg,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Concentric Vinyl Micro-Grooves
                        CustomPaint(
                          size: Size(widget.size * 0.88, widget.size * 0.88),
                          painter: _VinylGroovesPainter(),
                        ),

                        // Center Vinyl Label
                        Container(
                          width: widget.size * 0.36,
                          height: widget.size * 0.36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.kappogyGradient,
                            border: Border.all(color: Colors.white24, width: 1.5),
                            boxShadow: SkeuoTokens.raisedSm,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Ω',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                Text(
                                  widget.track?.codec ?? '33 RPM',
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Center Spindle Hole
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2C303E),
                            boxShadow: SkeuoTokens.sunkenWell,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ToneArm Needle (Pivoting from Top Right)
          Positioned(
            top: 10,
            right: 14,
            child: Transform.rotate(
              angle: widget.isPlaying ? 0.35 : 0.05,
              alignment: Alignment.topRight,
              child: Container(
                width: 70,
                height: 4.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF70788C), Color(0xFF383C4A)],
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                  boxShadow: SkeuoTokens.raisedSm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.kappogyRed,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: SkeuoTokens.ledGlow(AppColors.kappogyRed),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0x18FFFFFF);

    for (double r = 24.0; r < size.width / 2 - 4; r += 3.5) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
