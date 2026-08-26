import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/dynamic_range_analyzer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import 'audio_providers.dart';

class DynamicRangeMeterSheet extends ConsumerWidget {
  const DynamicRangeMeterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DynamicRangeMeterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackStateProvider);
    final track = playbackState.currentTrack;
    final report = DynamicRangeReport.evaluate(
      trackTitle: track?.title ?? 'Studio Master Track',
      customPeak: -0.3,
      customRms: -13.8,
      customDr: 14,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: SkeuoTokens.raisedLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: AppColors.kappogyGreen, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'AUDIOPHILE DYNAMIC RANGE (DR) METER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SkeuoButton(
                  size: 32,
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Analog DR Needle Gauge Panel
                  SkeuoPanel(
                    padding: const EdgeInsets.all(14),
                    showCornerScrews: true,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              track?.title ?? 'No Track Loaded',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // True-Peak Clipping Warning Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: report.hasTruePeakClipping ? AppColors.kappogyRed : AppColors.panelSunken,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 11,
                                    color: report.hasTruePeakClipping ? Colors.white : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    report.hasTruePeakClipping ? 'TRUE-PEAK CLIPPING' : 'CLEAN HEADROOM',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: report.hasTruePeakClipping ? Colors.white : AppColors.kappogyGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Arc Needle Meter
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF181512), // Warm vintage dark gauge face
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: SkeuoTokens.sunkenWell,
                            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                          ),
                          child: CustomPaint(
                            painter: _DrGaugePainter(drScore: report.drScore),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Large DR Score & Dynamic Grade Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TT DYNAMIC RANGE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  'DR${report.drScore}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: report.grade.color,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: report.grade.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: report.grade.color, width: 1.0),
                              ),
                              child: Text(
                                report.grade.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: report.grade.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Loudness Metrics Grid
                  Row(
                    children: [
                      _buildMetricTile('PEAK LEVEL', '${report.peakDbfs.toStringAsFixed(1)} dBFS', AppColors.kappogyRed),
                      const SizedBox(width: 8),
                      _buildMetricTile('RMS LOUDNESS', '${report.rmsDbfs.toStringAsFixed(1)} dBFS', AppColors.ledCyan),
                      const SizedBox(width: 8),
                      _buildMetricTile('CREST FACTOR', '${report.crestFactorDb.toStringAsFixed(1)} dB', AppColors.kappogyGreen),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Technical Guidance Card
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.ledCyan, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'ABOUT TT DYNAMIC RANGE METERING',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledCyan, letterSpacing: 0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report.grade.description,
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary, height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Higher DR scores indicate natural acoustic dynamics and punching transient impact. Lower DR scores (DR1-DR6) reflect hyper-compressed masters from the Loudness War.',
                          style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
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

  Widget _buildMetricTile(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.panelRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrGaugePainter extends CustomPainter {
  final int drScore;
  _DrGaugePainter({required this.drScore});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.90);
    final radius = size.height * 0.75;

    // Draw scale arcs
    final bgArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Colors.white10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgArcPaint,
    );

    // Draw active colored segments:
    // DR1..5 (Red), DR6..8 (Yellow), DR9..13 (Cyan), DR14..20 (Green)
    final redArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = AppColors.kappogyRed;
    final yellowArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = AppColors.kappogyYellow;
    final cyanArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = AppColors.ledCyan;
    final greenArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = AppColors.kappogyGreen;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi * 0.25, false, redArcPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi + (pi * 0.25), pi * 0.15, false, yellowArcPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi + (pi * 0.40), pi * 0.25, false, cyanArcPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi + (pi * 0.65), pi * 0.35, false, greenArcPaint);

    // Calculate needle angle for DR score (1 to 20 mapped to pi to 2*pi)
    final normalized = ((drScore - 1) / 19.0).clamp(0.0, 1.0);
    final needleAngle = pi + (normalized * pi);

    final needlePaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + radius * 0.90 * cos(needleAngle),
      center.dy + radius * 0.90 * sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    // Needle pivot screw
    final screwPaint = Paint()..color = const Color(0xFFD4AF37); // Brass pivot screw
    canvas.drawCircle(center, 5.0, screwPaint);
  }

  @override
  bool shouldRepaint(covariant _DrGaugePainter oldDelegate) => oldDelegate.drScore != drScore;
}
