import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skeuo_tokens.dart';

/// Multi-Band LED VU Meter & Audio Spectrum Visualizer with Kappogy Tri-Color Gradient
class SkeuoVUMeter extends StatefulWidget {
  final bool isPlaying;
  final double level; // 0.0 to 1.0
  final int bands;
  final int segmentsPerBand;
  final double height;
  final double width;
  final bool isStereo;

  const SkeuoVUMeter({
    super.key,
    this.isPlaying = false,
    this.level = 0.7,
    this.bands = 16,
    this.segmentsPerBand = 12,
    this.height = 70.0,
    this.width = double.infinity,
    this.isStereo = false,
  });

  @override
  State<SkeuoVUMeter> createState() => _SkeuoVUMeterState();
}

class _SkeuoVUMeterState extends State<SkeuoVUMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _rnd = Random(42);
  late List<double> _bandLevels;

  @override
  void initState() {
    super.initState();
    _bandLevels = List.filled(widget.bands, 0.0);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..addListener(() {
        if (widget.isPlaying) {
          setState(() {
            for (int i = 0; i < widget.bands; i++) {
              final noise = (_rnd.nextDouble() * 0.4) - 0.2;
              final target = (widget.level + noise).clamp(0.05, 1.0);
              _bandLevels[i] = (_bandLevels[i] * 0.4) + (target * 0.6);
            }
          });
        } else {
          setState(() {
            for (int i = 0; i < widget.bands; i++) {
              _bandLevels[i] = _bandLevels[i] * 0.8;
            }
          });
        }
      });

    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelSunken,
        borderRadius: BorderRadius.circular(10),
        boxShadow: SkeuoTokens.sunkenWell,
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.bands, (bandIdx) {
          final bandLevel = _bandLevels[bandIdx];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(widget.segmentsPerBand, (segIdx) {
                  // Inverted segment index (top is high frequency/peak)
                  final segNormalized = (widget.segmentsPerBand - 1 - segIdx) /
                      (widget.segmentsPerBand - 1);
                  final isActive = segNormalized <= bandLevel;

                  // Tri-color logic: Bottom = Green, Middle = Yellow, Top = Red
                  Color segColor;
                  if (segNormalized > 0.75) {
                    segColor = AppColors.kappogyRed;
                  } else if (segNormalized > 0.45) {
                    segColor = AppColors.kappogyYellow;
                  } else {
                    segColor = AppColors.kappogyGreen;
                  }

                  return Container(
                    height: 2.8,
                    margin: const EdgeInsets.symmetric(vertical: 0.8),
                    decoration: BoxDecoration(
                      color: isActive ? segColor : AppColors.ledInactive,
                      borderRadius: BorderRadius.circular(1.0),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: segColor.withValues(alpha: 0.7),
                                blurRadius: 4,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
}
