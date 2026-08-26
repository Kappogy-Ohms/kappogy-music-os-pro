import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../domain/track_model.dart';
import '../domain/turntable_theme_model.dart';

/// Tactile Multi-Style Studio Turntable & Reel-to-Reel Deck
class TurntableVisualizer extends ConsumerStatefulWidget {
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
  ConsumerState<TurntableVisualizer> createState() => _TurntableVisualizerState();
}

class _TurntableVisualizerState extends ConsumerState<TurntableVisualizer>
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
    final theme = ref.watch(deckVisualizerThemeProvider);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Sunken Platter Well
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getPlatterWellGradient(theme),
              boxShadow: SkeuoTokens.sunkenWell,
              border: Border.all(color: _getPlatterBorderColor(theme), width: 1.5),
            ),
          ),

          // Rotating Deck Content based on Theme
          GestureDetector(
            onPanStart: (details) {
              final center = Offset(widget.size / 2, widget.size / 2);
              final touchOffset = details.localPosition - center;
              _lastTouchAngle = atan2(touchOffset.dy, touchOffset.dx);
            },
            onPanUpdate: (details) {
              final center = Offset(widget.size / 2, widget.size / 2);
              final touchOffset = details.localPosition - center;
              final currentTouchAngle = atan2(touchOffset.dy, touchOffset.dx);
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
                final angle = _manualAngle + (_rotationController.value * 2 * pi);

                if (theme == DeckVisualizerTheme.reelToReel) {
                  return _buildReelToReelDeck(angle);
                }

                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: widget.size * 0.90,
                    height: widget.size * 0.90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _getPlatterGradient(theme),
                      boxShadow: SkeuoTokens.raisedLg,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Platter Details / Grooves Painter
                        CustomPaint(
                          size: Size(widget.size * 0.88, widget.size * 0.88),
                          painter: _getPlatterPainter(theme),
                        ),

                        // Center Vinyl / Acrylic Label
                        Container(
                          width: widget.size * 0.36,
                          height: widget.size * 0.36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _getLabelGradient(theme),
                            border: Border.all(color: _getLabelBorder(theme), width: 1.5),
                            boxShadow: SkeuoTokens.raisedSm,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getCenterSymbol(theme),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: _getLabelTextColor(theme),
                                    fontFamily: 'serif',
                                  ),
                                ),
                                Text(
                                  widget.track?.codec ?? '33 RPM',
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    color: _getLabelTextColor(theme),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme == DeckVisualizerTheme.clearaudioAcrylic
                                ? const Color(0xFFD4AF37)
                                : const Color(0xFF2C303E),
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

          // ToneArm Needle (Turntable Modes)
          if (theme != DeckVisualizerTheme.reelToReel)
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
                    gradient: LinearGradient(
                      colors: theme == DeckVisualizerTheme.clearaudioAcrylic
                          ? const [Color(0xFFD4AF37), Color(0xFF996515)]
                          : const [Color(0xFF70788C), Color(0xFF383C4A)],
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
                        color: theme == DeckVisualizerTheme.neonCyber ? const Color(0xFF00E5FF) : AppColors.kappogyRed,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: SkeuoTokens.ledGlow(theme == DeckVisualizerTheme.neonCyber ? const Color(0xFF00E5FF) : AppColors.kappogyRed),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Technics 1200 Red Laser Strobe Lamp
          if (theme == DeckVisualizerTheme.technics1200)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF1744),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1744).withValues(alpha: widget.isPlaying ? 0.9 : 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.flash_on_rounded, size: 8, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 10.5" Studio Reel-to-Reel Aluminum Tape Deck
  Widget _buildReelToReelDeck(double angle) {
    final spoolSize = widget.size * 0.44;

    return Container(
      width: widget.size * 0.92,
      height: widget.size * 0.92,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3E4E), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Magnetic Tape Path
          Positioned(
            bottom: widget.size * 0.22,
            child: Container(
              width: widget.size * 0.70,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Magnetic Head Block (Center Bottom)
          Positioned(
            bottom: widget.size * 0.16,
            child: Container(
              width: 32,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF757575),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24, width: 0.8),
                boxShadow: SkeuoTokens.raisedSm,
              ),
            ),
          ),
          // Left Aluminum Takeup Reel
          Positioned(
            left: widget.size * 0.04,
            top: widget.size * 0.12,
            child: Transform.rotate(
              angle: angle,
              child: _buildAluminumSpool(spoolSize),
            ),
          ),
          // Right Aluminum Supply Reel
          Positioned(
            right: widget.size * 0.04,
            top: widget.size * 0.12,
            child: Transform.rotate(
              angle: angle * 1.02,
              child: _buildAluminumSpool(spoolSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAluminumSpool(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E), Color(0xFF424242)],
        ),
        boxShadow: SkeuoTokens.raisedSm,
        border: Border.all(color: Colors.white54, width: 1.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3-Hole Precision Cutouts
          for (int i = 0; i < 3; i++)
            Transform.rotate(
              angle: (i * 2 * pi) / 3,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: size * 0.16),
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1B1D24),
                  ),
                ),
              ),
            ),
          // Center Spindle Lock
          Container(
            width: size * 0.30,
            height: size * 0.30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF212121),
            ),
            child: const Center(
              child: Text(
                'Ω',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Gradient _getPlatterWellGradient(DeckVisualizerTheme theme) {
    switch (theme) {
      case DeckVisualizerTheme.clearaudioAcrylic:
        return const RadialGradient(colors: [Color(0xFF2A2D3A), Color(0xFF14161D)]);
      case DeckVisualizerTheme.neonCyber:
        return const RadialGradient(colors: [Color(0xFF0F1B2B), Color(0xFF060911)]);
      case DeckVisualizerTheme.technics1200:
        return const RadialGradient(colors: [Color(0xFF222530), Color(0xFF111217)]);
      case DeckVisualizerTheme.reelToReel:
        return const RadialGradient(colors: [Color(0xFF2D313F), Color(0xFF1A1C24)]);
      case DeckVisualizerTheme.classicStudio:
        return const RadialGradient(colors: [Color(0xFF1C1E26), Color(0xFF0F1015)]);
    }
  }

  Color _getPlatterBorderColor(DeckVisualizerTheme theme) {
    switch (theme) {
      case DeckVisualizerTheme.clearaudioAcrylic:
        return const Color(0xFFD4AF37);
      case DeckVisualizerTheme.neonCyber:
        return const Color(0xFF00E5FF);
      case DeckVisualizerTheme.technics1200:
        return const Color(0xFFFF1744);
      default:
        return AppColors.borderSubtle;
    }
  }

  Gradient _getPlatterGradient(DeckVisualizerTheme theme) {
    switch (theme) {
      case DeckVisualizerTheme.clearaudioAcrylic:
        return RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            const Color(0xFFB0BEC5).withValues(alpha: 0.4),
            const Color(0xFF37474F).withValues(alpha: 0.7),
          ],
        );
      case DeckVisualizerTheme.neonCyber:
        return const RadialGradient(
          colors: [Color(0xFF101B2B), Color(0xFF080D18), Color(0xFF020408)],
        );
      default:
        return const RadialGradient(
          colors: [Color(0xFF242732), Color(0xFF14161E), Color(0xFF0A0B0F)],
        );
    }
  }

  CustomPainter _getPlatterPainter(DeckVisualizerTheme theme) {
    switch (theme) {
      case DeckVisualizerTheme.technics1200:
        return _TechnicsStrobePainter();
      case DeckVisualizerTheme.clearaudioAcrylic:
        return _AcrylicFrostedPainter();
      case DeckVisualizerTheme.neonCyber:
        return _NeonCyberGroovesPainter();
      default:
        return _VinylGroovesPainter();
    }
  }

  Gradient _getLabelGradient(DeckVisualizerTheme theme) {
    switch (theme) {
      case DeckVisualizerTheme.clearaudioAcrylic:
        return const LinearGradient(colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFF996515)]);
      case DeckVisualizerTheme.neonCyber:
        return const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFD500F9)]);
      case DeckVisualizerTheme.technics1200:
        return const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)]);
      default:
        return AppColors.kappogyGradient;
    }
  }

  Color _getLabelBorder(DeckVisualizerTheme theme) {
    return theme == DeckVisualizerTheme.neonCyber ? const Color(0xFF00E5FF) : Colors.white24;
  }

  String _getCenterSymbol(DeckVisualizerTheme theme) {
    return 'Ω';
  }

  Color _getLabelTextColor(DeckVisualizerTheme theme) {
    switch (theme) {
      case DeckVisualizerTheme.technics1200:
        return Colors.white;
      case DeckVisualizerTheme.neonCyber:
        return Colors.black;
      default:
        return Colors.black87;
    }
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

class _TechnicsStrobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Strobe dots outer band
    final dotPaint = Paint()..color = const Color(0xFFE0E0E0);
    const int dots = 48;
    for (int i = 0; i < dots; i++) {
      final angle = (i * 2 * pi) / dots;
      final x = center.dx + (radius - 2) * cos(angle);
      final y = center.dy + (radius - 2) * sin(angle);
      canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
    }

    // Concentric grooves
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0x22FFFFFF);

    for (double r = 24.0; r < radius - 8; r += 3.5) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AcrylicFrostedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0x30D4AF37);

    for (double r = 30.0; r < size.width / 2 - 6; r += 8.0) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeonCyberGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0x6600E5FF);

    final magentaPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0x66D500F9);

    int idx = 0;
    for (double r = 24.0; r < size.width / 2 - 4; r += 4.5) {
      canvas.drawCircle(center, r, (idx++ % 2 == 0) ? cyanPaint : magentaPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
