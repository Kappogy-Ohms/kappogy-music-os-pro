import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';

class EqCurveVisualizer extends StatelessWidget {
  final List<double> gains; // 10 gain values in dB (-15.0 to +15.0)
  final double height;

  const EqCurveVisualizer({
    super.key,
    required this.gains,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelWell,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        boxShadow: SkeuoTokens.sunkenWell,
      ),
      child: CustomPaint(
        painter: _EqSplineCurvePainter(gains: gains),
        child: Container(),
      ),
    );
  }
}

class _EqSplineCurvePainter extends CustomPainter {
  final List<double> gains;

  _EqSplineCurvePainter({required this.gains});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Grid Lines (0 dB Center line, +15 dB, -15 dB)
    final gridPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final centerPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // +15 dB
    canvas.drawLine(const Offset(0, 4), Offset(size.width, 4), gridPaint);
    // 0 dB (Center)
    final centerY = size.height / 2.0;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), centerPaint);
    // -15 dB
    canvas.drawLine(Offset(0, size.height - 4), Offset(size.width, size.height - 4), gridPaint);

    if (gains.isEmpty) return;

    // 2. Map 10 gain points to Canvas Coordinates
    final stepX = size.width / (gains.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < gains.length; i++) {
      final x = i * stepX;
      // Clamped from -15 to +15 dB
      final normalized = (gains[i].clamp(-15.0, 15.0) + 15.0) / 30.0; // 0.0 to 1.0
      final y = size.height - (normalized * (size.height - 8) + 4);
      points.add(Offset(x, y));
    }

    // 3. Create Smooth Cubic Bézier Spline Path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final ctrl1 = Offset(p0.dx + (p1.dx - p0.dx) / 2.0, p0.dy);
      final ctrl2 = Offset(p0.dx + (p1.dx - p0.dx) / 2.0, p1.dy);
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p1.dx, p1.dy);
    }

    // 4. Draw Gradient Fill Under Spline
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.kappogyRed.withValues(alpha: 0.35),
          AppColors.kappogyYellow.withValues(alpha: 0.2),
          AppColors.kappogyGreen.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw Glowing Spline Stroke
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.kappogyRed, AppColors.kappogyYellow, AppColors.kappogyGreen],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);

    // 6. Draw Control Nodes
    final nodePaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    for (final pt in points) {
      canvas.drawCircle(pt, 2.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EqSplineCurvePainter oldDelegate) {
    return oldDelegate.gains != gains;
  }
}
